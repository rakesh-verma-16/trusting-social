require_relative 'model/ActivePhone'
require_relative 'utilities/SheetReader'

# Main method to process a CSV of numbers to return last user's activation date.
# Params:
# +sheet_path+:: Path to the sheet.
# +batch_size+:: Batch size to proces
def main(sheet_path, batch_size)
	response = create_timelines_from_numbers(sheet_path, batch_size)
	SheetReader.write_to_file(response, File.basename(sheet_path, ".csv"))
end

private
def create_timelines_from_numbers(sheet_path, batch_size)
	ActivePhone.create_table

	SheetReader.process_csv(sheet_path, batch_size)

	ActivePhone.find_last_users_activation_date
end


