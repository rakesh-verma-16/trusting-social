require_relative 'main'

# path to the input csv sheet
sheet_path = ARGV[0]
if (!sheet_path || File.extname(sheet_path) != '.csv')
	raise IOError.new "Require at least one param in csv format.\n"
end

#Batch size, default 1000
batch_size = (ARGV[1] || 10000).to_i

print main(sheet_path, batch_size)