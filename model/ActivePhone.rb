require 'sqlite3'

class ActivePhone

	def self.create_table
		db = SQLite3::Database.new 'ts.db'

		# Create a table
		db.execute "DROP TABLE IF EXISTS phones"
		result = db.execute <<-SQL
  			CREATE TABLE phones (
  				phone_number INT NOT NULL,
  				start_date TEXT NOT NULL,
  				end_date TEXT	
  			);

  			CREATE INDEX PHONE_NUMBER_INDEX ON phones(phone_number);
		SQL
	end

	def self.bulk_insert(phone_hash)
		db = SQLite3::Database.new 'ts.db'
		phone_hash.each do |key, data_set|
			db.transaction
				data_set.each do |sdate, edate|
					binding.pry
					if !edate
						edate = Date.today.to_s
					end
					sql_string = "insert into phones values (#{key}, date(\""+sdate+"\"),date(\""+edate+"\"));"
					db.execute sql_string
				end
			db.commit
		end
	end

	def self.delete_all_records_of_phone_numbers(phone_numbers)
		db = SQLite3::Database.new 'ts.db'
		db.execute "
		    	DELETE FROM phones
		    	WHERE phone_number in ("+phone_numbers.join(',')+");
		    "
	end

	
	def self.fetch_records_by_phone_numbers(phone_numbers)
		db = SQLite3::Database.new 'ts.db'
		db.execute "
		    SELECT * from phones 
		    where phone_number in ("+phone_numbers.join(',')+") 
		    order by phone_number, start_date asc;"
	end

	def self.find_max
		db = SQLite3::Database.new 'ts.db'
		db.execute "
			select phone_number, MAX(start_date) 
			from phones group by phone_number 
	 		order by start_date desc;
 		"
	end

end