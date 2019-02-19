require 'sqlite3'

# Open a SQLite 3 database file
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

# # # Insert some data into it
# [[123, '1', '2', 1], [234, '11', '32', 1]].each do |pair|
#   db.execute 'insert into phones values (?, ?, ?, ?)', pair
# end

# # Find some records
# db.execute 'SELECT * FROM phones' do |row|
#   print row
# end