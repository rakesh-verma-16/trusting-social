require_relative 'model/ActivePhone'
require_relative 'utilities/SheetReader'

# Main method to process a CSV of numbers to return last user's activation date.
# Params:
# +sheet_path+:: Path to the sheet.
# +batch_size+:: Batch size to process limited number of rows from CSV at a time.
def main(sheet_path = "test-dataset/small-miscellaneous-data.csv", batch_size = 10000)
	ActivePhone.create_table
	File.open(sheet_path) do |file|
		header_row = true
		file.lazy.each_slice(batch_size) do |lines|
			if (header_row) 
	  			lines.slice!(0)
	  			header_row = false
	  		end
			SheetReader.process(lines)
		end
	end

	result = ActivePhone.find_max
	pp result
end