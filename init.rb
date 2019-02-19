require_relative 'model/ActivePhone'
require_relative 'utilities/SheetReaderInterface'


def main(sheet_file = "10_data.csv", batch_size = 100000)
	ActivePhone.create_table
	File.open(sheet_file) do |file|
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