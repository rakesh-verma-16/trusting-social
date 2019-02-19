require 'csv'
require 'pry'
require 'pp'
require_relative '../model/ActivePhone'

class SheetReader

	public

	def self.process(lines)
	    csv_batch_results_mapping = {}
	    CSV.parse(lines.join) do |row|
	    	upsert_indexed_by_first(csv_batch_results_mapping, row)
	    end

		phone_numbers_in_current_batch = csv_batch_results_mapping.keys.map(&:to_i)
	    db_results_mapping = create_db_results_mapping(csv_batch_results_mapping, phone_numbers_in_current_batch)
	    csv_batch_results_mapping = merge_and_sort_mappings(db_results_mapping, csv_batch_results_mapping, phone_numbers_in_current_batch)
		create_divisions(csv_batch_results_mapping)
		ActivePhone.bulk_insert(csv_batch_results_mapping)
	end

	private

	def self.create_db_results_mapping(master_hash, phone_numbers_in_current_batch)
	    master_hash.map do |key, value|
	    	master_hash[key].sort!
	    end

	    result = ActivePhone.fetch_records_by_phone_numbers(phone_numbers_in_current_batch)
	    ActivePhone.delete_all_records_of_phone_numbers(phone_numbers_in_current_batch)

	    db_results_mapping = hash_append_array(result)
	end

	def self.hash_append_array(master_hash)
		resultant_hash = {}
		master_hash.each do |item|
			upsert_indexed_by_first(resultant_hash, item)
		end
		resultant_hash
	end

	def self.upsert_indexed_by_first(master_hash, array)
		if master_hash[array.first]
	    	master_hash[array.first] << [array[1], array[2]]
	    else
	    	master_hash[array.first] = [[array[1], array[2]]]
	    end
	end


	def self.merge_and_sort_mappings(db_hash, memory_hash, phone_numbers)
		phone_numbers.each do |num|
			if (db_hash[num])
				memory_hash[num.to_s] = (db_hash[num] + memory_hash[num.to_s]).sort!
			end
		end
		return memory_hash
	end

	def self.create_divisions(phone_hash)
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