require 'csv'
require 'pry'
require 'pp'
require_relative '../model/ActivePhone'

class SheetReader

	def self.process(lines)
	    phone_hash = {}
	    CSV.parse(lines.join) do |row|
	    	upsert_indexed_by_first(phone_hash, row)
	    end
	    phone_hash.map do |key, value|
	    	phone_hash[key].sort!
	    end
	    phone_numbers = phone_hash.keys.map(&:to_i)
	    result = ActivePhone.fetch_records_by_phone_numbers(phone_numbers)
	    ActivePhone.delete_all_records_of_phone_numbers(phone_numbers)

	    #Merge Sort
	    result_wala_hash = hash_append_array(result)
	    phone_hash = merge_hashe_sort(result_wala_hash, phone_hash, phone_numbers)
		merge_batch(phone_hash)
		ActivePhone.bulk_insert(phone_hash)
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


	def self.merge_hashe_sort(db_hash, memory_hash, phone_numbers)
		phone_numbers.each do |num|
			if (db_hash[num])
				memory_hash[num.to_s] = (db_hash[num] + memory_hash[num.to_s]).sort!
			end
		end
		return memory_hash
	end

	def self.merge_batch(phone_hash)
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