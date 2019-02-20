require 'csv'
require_relative '../model/ActivePhone'

class SheetReaderHelper
	# Sets the headers to the resultant CSV file
	# Params:
	# +result+:: result data to which header should be added
	def self.set_headers_to_data(result)
		result.unshift(['PHONE_NUMBER','REAL_ACTIVATION_DATE'])
	end

	# Creates a mapping of previously processed batches and current batch to create
	# a single timeline for numbers being processed in current batch.
	# Params:
	# +master_hash+:: Phone timeline mapping obtained from current batch
	# +phone_data_for_current_batch+:: Mapping obtained from db of previously processed batches
	def self.create_db_results_mapping(master_hash, phone_data_for_current_batch)
	    master_hash.map do |key, value|
	    	master_hash[key].sort!
	    end

	    db_result = ActivePhone.fetch_records_by_phone_numbers(phone_data_for_current_batch)
	    ActivePhone.delete_all_records_of_phone_numbers(phone_data_for_current_batch)

	    db_results_mapping = create_hash_from_phone_array(db_result)
	end

	# Upserts a hash for a key
	# if key already present in hash, append
	# else, create the key and add data
	# Params:
	#+master_hash+:: Hash to which data to be appended or inserted
	#+array+:: data in array format which is to be inserted/appended to hash
	def self.upsert_indexed_by_first(master_hash, array)
		if master_hash[array.first]
	    	master_hash[array.first] << [array[1], array[2]]
	    else
	    	master_hash[array.first] = [[array[1], array[2]]]
	    end
	end

	# Merges the db data and in memory data to be processed together
	# Params:
	# +db_hash+:: data obtained from db in hash format
	# +memory_hash+:: data obtained by processing current batch.
	# +phone_numbers+:: integer phone numbers obtained in current batch
	def self.merge_and_sort_mappings(db_hash, memory_hash, phone_numbers)
		phone_numbers.each do |num|
			if (db_hash[num])
				memory_hash[num.to_s] = (db_hash[num] + memory_hash[num.to_s]).sort!
			end
		end
		return memory_hash
	end

	# Private methods section begins
	private

	# Creates an hash indexed on phone_number from an array
	# Params:
	# +db_data_array+:: Array to be converted to hash
	def self.create_hash_from_phone_array(db_data_array)
		resultant_hash = {}
		db_data_array.each do |item|
			upsert_indexed_by_first(resultant_hash, item)
		end
		resultant_hash
	end
end

