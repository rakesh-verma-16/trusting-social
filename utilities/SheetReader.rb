require 'csv'
require_relative '../model/ActivePhone'
require_relative 'SheetReaderHelper'

class SheetReader

	public

	# Takes the sheet path, breaks it into a batch of given size
	# operates over the batch and process it in sync with previously 
	# processed batches.
	# Params:
	# +sheet_path+:: Path to the sheet file.
	# +batch_size+:: Batch size to be processed
	def self.process_csv(sheet_path, batch_size)
		File.open(sheet_path) do |file|
			header_row = true
			file.lazy.each_slice(batch_size) do |lines|
				if (header_row) 
	  				lines.slice!(0)
	  				header_row = false
	  			end
				process_batch_data(lines)
			end
		end
	end

	# Creates a new output file to store the results in a CSV
	# Params:
	# +data+:: result data to be written to CSV.
	# +file_basename+:: name of the file without extensions.
	def self.write_to_file(data, file_basename)
		SheetReaderHelper.set_headers_to_data(data)
		filename = "result-file/"+file_basename+"-result.csv"
		File.open(filename, "w") {|f| f.write(data.inject([]) {
		    |csv, data| csv << CSV.generate_line(data) 
		}.join(""))}
		"Data written to #{filename}"
	end

	# Private methods section begins
	private

	# Takes the limited lines of CSV (batch size) as input
	# Compares the phone and creates a mapping of previous batch results and current results
	# Inserts the resulting set back to storing file (database)
	# Params:
	# +lines+:: String of lines containing batched data from input csv
	def self.process_batch_data(lines)
	    csv_batch_results_mapping = {}
	    CSV.parse(lines.join) do |row|
	    	SheetReaderHelper.upsert_indexed_by_first(csv_batch_results_mapping, row)
	    end

		phone_numbers_in_current_batch = csv_batch_results_mapping.keys.map(&:to_i)
	    db_results_mapping = SheetReaderHelper.create_db_results_mapping(csv_batch_results_mapping, phone_numbers_in_current_batch)
	    csv_batch_results_mapping = SheetReaderHelper.merge_and_sort_mappings(db_results_mapping, csv_batch_results_mapping, phone_numbers_in_current_batch)
		create_timeline_based_division(csv_batch_results_mapping)
		ActivePhone.bulk_insert(csv_batch_results_mapping)
	end

	# Main method to merge timelines for a number based on continous use
	# Params:
	# +phone_hash+:: Hash which is to be processed based on phone numbers
	def self.create_timeline_based_division(phone_hash)
		phone_hash.each do |phone_number, array_of_dates|
			comparing_array = array_of_dates.dup
			final_keywise_result = []
			array_of_dates.each do |sdate, edate|
				comparing_array.each do |s,e|
					if sdate == e
						sdate = s
						array_of_dates.delete([sdate, edate])
					elsif edate == s
						edate = e
						array_of_dates.delete([s,e])
					end
				end
				final_keywise_result << [sdate, edate]
			end
			phone_hash[phone_number] = final_keywise_result.uniq
		end
	end
end