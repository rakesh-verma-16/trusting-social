require 'test/unit'
require_relative "../utilities/SheetReader"
require_relative "../main"

class SheetReaderTest < Test::Unit::TestCase

	def test_single_phone_number
		input_file = "test-dataset/test-data-same-number-9.csv"
		expected_result_file = "result-file/test-data-same-number-9-result.csv"
		actual_result_file = "test-dataset/test-data-same-number-9-solution.csv"
		main(input_file, 100)
		perform_test(expected_result_file, actual_result_file)
	end

	def test_single_phone_number_second
		input_file = "test-dataset/test-data-same-number-1.csv"
		expected_result_file = "result-file/test-data-same-number-1-result.csv"
		actual_result_file = "test-dataset/test-data-same-number-1-solution.csv"
		main(input_file, 100)
		perform_test(expected_result_file, actual_result_file)
	end

	def test_small_random_data
		input_file = "test-dataset/small-miscellaneous-data.csv"
		expected_result_file = "result-file/small-miscellaneous-data-result.csv"
		actual_result_file = "test-dataset/small-data-solution.csv"
		main(input_file, 10)
		perform_test(expected_result_file, actual_result_file)
	end

	def test_medium_random_data
		input_file = "test-dataset/medium-miscellaneous-data.csv"
		expected_result_file = "result-file/medium-miscellaneous-data-result.csv"
		actual_result_file = "test-dataset/medium-data-solution.csv"
		main(input_file, 1000)
		perform_test(expected_result_file, actual_result_file)
	end

	def test_large_random_data
		input_file = "test-dataset/large-miscellaneous-data.csv"
		expected_result_file = "result-file/large-miscellaneous-data-result.csv"
		actual_result_file = "test-dataset/large-data-solution.csv"
		main(input_file, 100000)
		perform_test(expected_result_file, actual_result_file)
	end

	private

	# Compares two files and asserts true if they are identical
	def perform_test(expected_result_file, actual_result_file)
		is_identical = FileUtils.identical?(expected_result_file, actual_result_file)
		assert(is_identical, "They were supposed to be identical")
		File.delete(expected_result_file) if File.exist?(expected_result_file)
	end
end
