require 'csv'
require 'pry'
require 'pp'
require 'sqlite3'

class SheetReader

	def self.read

		db = SQLite3::Database.new 'ts.db'
		header_row = true
		File.open("big_data.csv") do |file|
		  file.lazy.each_slice(10) do |lines|
		  	if (header_row) 
		  		lines.slice!(0)
		  		header_row = false
		  	end
		    phone_hash = {}
		    CSV.parse(lines.join) do |row|
		    	if phone_hash[row[0]]
		    		phone_hash[row[0]] << [row[1], row[2]]
		    	else
		    		phone_hash[row[0]] = [[row[1], row[2]]]
		    	end
		    end

		    phone_hash.map do |key, value|
		    	phone_hash[key].sort!
		    end

			phone_numbers = phone_hash.keys.map(&:to_i)

		    result = db.execute "
		    SELECT * from phones 
		    where phone_number in ("+phone_numbers.join(',')+") order by phone_number, start_date asc;"

		    db.execute "
		    	DELETE FROM phones
		    	WHERE phone_number in ("+phone_numbers.join(',')+");
		    "
		    #Merge Sort
		    binding.pry

		    result_wala_hash = {}
		    result.each do |x|
	    		if result_wala_hash[x[0]]
	    			result_wala_hash[x[0]] << [x[1], x[2]]
	    		else
	    			result_wala_hash[x[0]] = [[x[1], x[2]]]
	    		end 
		    end

		    phone_hash = merge_hashe_sort(result_wala_hash, phone_hash, phone_numbers)
			merge_batch(phone_hash)
			phone_hash.each do |key, data_set|
				db.transaction
				data_set.each do |sdate, edate|
					sql_string = "insert into phones values (#{key}, date(\""+sdate+"\"),date(\""+edate+"\"));"
					db.execute sql_string
				end
				db.commit
			end
		  end
		end

		final_result = db.execute "select phone_number, MAX(start_date) 
		from phones group by phone_number 
		 order by start_date desc;"
		pp final_result
	end

	def hash_append_array(master_hash, array_to_append)
		resultant_hash = {}
		master_hash.each do |item|
			
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