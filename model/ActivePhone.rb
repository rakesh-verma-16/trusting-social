#!/usr/bin/env ruby
require 'sqlite3'

class ActivePhone

	# Creates a db file names ts {trusting-social}
	def self.create_table
		db = SQLite3::Database.new 'ts.db'

		db.execute "DROP TABLE IF EXISTS phones"
		result = db.execute <<-SQL
  			CREATE TABLE phones (
  				phone_number INT NOT NULL,
  				start_date TEXT NOT NULL,
  				end_date TEXT	
  			);

  			# Indexing phone number because we would be querying on it frequently.
  			CREATE INDEX PHONE_NUMBER_INDEX ON phones(phone_number);
		SQL
	end

	# Inserts simplified data into database into atomic transaction
	# phone_hash is a mapping between phone number and arrays of the time spans it 
	# was used for.
	#
	# @param phone_hash   hash map { :integer => [[string, string],[string, string]]}
	def self.bulk_insert(phone_hash)
		db = SQLite3::Database.new 'ts.db'
		phone_hash.each do |key, data_set|
			db.transaction
				data_set.each do |sdate, edate|
					# if no end date is passed, set the end date to today's date
					if !edate
						edate = Date.today.to_s
					end
					sql_string = "insert into phones values (#{key},
						date(\""+sdate+"\"),date(\""+edate+"\"));"
					db.execute sql_string
				end
			db.commit
		end
	end

	# Deletes all entries from db for a set of phone numbers.
	# @param phone_numbers    array of integers
	def self.delete_all_records_of_phone_numbers(phone_numbers)
		db = SQLite3::Database.new 'ts.db'
		db.execute "
		    	DELETE FROM phones
		    	WHERE phone_number in ("+phone_numbers.join(',')+");
		    "
	end

	# Getter method for set of phone numbers.
	# @param phone_numbers    array of integers
	def self.fetch_records_by_phone_numbers(phone_numbers)
		db = SQLite3::Database.new 'ts.db'
		db.execute "
		    SELECT * from phones 
		    where phone_number in ("+phone_numbers.join(',')+") 
		    order by phone_number, start_date asc;"
	end

	# Getter method to return all last user's activation date
	# for all the phone numbers from database.
	def self.find_max
		db = SQLite3::Database.new 'ts.db'
		db.execute "
			select phone_number, MAX(start_date) 
			from phones group by phone_number 
	 		order by start_date desc;
 		"
	end

end