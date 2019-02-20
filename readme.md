# Project Overview

This project takes a CSV file in the following format

```
PHONE_NUMBER,ACTIVATION_DATE,DEACTIVATION_DATE
```
and processes the data to find the last activation date of a phone number.
Last activation date doesn't include the dates in which the phone number plan was changed from postPaid to prepaid or vice-versace.

*A phone number is said to be activated only if there is a gap of 1-2 months between last de-activation date and the current activation date*

## Solution

Idea is to break the CSV into batches, consume a batch to find the timelines for each phone number in that batch and store it into the database.

For the next set of batches, we process them (the batches) with the existing and already simplified data stored in our database.

Here simplification term specifies that for each phone number, we have all the activation dates (not the ones where the plan is changed) from all the batches processed. 

In case, we come across any dates where the plan is changed for a particular phone number, we merge it to make a single entry.

For ex: 

```

Phone number => 9899585453
activation dates => [["1999-01-01", "1999-01-05"],
		["1999-01-05", "1999-01-10"],
		["1999-01-11", "1999-01-15"],
		["1999-01-20", "1999-01-25"]]

Simplified data would be:
activation dates => [["1999-01-01", "1999-01-15"],
					["1999-01-20", "1999-01-25"]]

```

All the continous sections of dates are merged into one section. 
After processing all the batches, final result is inserted into a result file under `result-file` directory in the following format

`PHONE_NUMBER,REAL_ACTIVATION_DATE`

## Getting Started

The program is to be initialized from ruby terminal. **Please follow the following instructions to run the program**:

-	Go to the project directory - 	`cd path_to_project`
-	Run the terminal - `irb`
-	Load the **main** file into terminal - `require_relative './main'`
-	call the **main function** with path to **the csv file** (default: "test-dataset/small-miscellaneous-data.csv") and **the batch size** (default 1000) -

	 `main "test-dataset/small-miscellaneous-data.csv",1000`

Expected output:
`"Data written to {{input-file-name}}-result.csv"` would be displayed in terminal.

A new file would be created in the `result-file` directory of the project with the same name as input file appened by `-result` before the CSV extension.

## Example

**Input CSV Content**:

```
PHONE_NUMBER,ACTIVATION_DATE,DEACTIVATION_DATE
0987000001,2016-03-01,2016-05-01
0987000002,2016-02-01,2016-03-01
0987000001,2016-01-01,2016-03-01
0987000001,2016-12-01,
0987000002,2016-03-01,2016-05-01
0987000003,2016-01-01,2016-01-10
0987000001,2016-09-01,2016-12-01
0987000002,2016-05-01,
0987000001,2016-06-01,2016-09-01
```

**Output CSV content**

```
PHONE_NUMBER,REAL_ACTIVATION_DATE
987000001,2016-06-01
987000002,2016-02-01
987000003,2016-01-01
```


### Pre-requisites
-	Ruby

### Libraries
-	SQLite3
-	CSV

### Installing the pre-requisites

- Install ruby - Download the package and follow instructions from - `http://rubyinstaller.org/`

- Install SQLITE3 - `gem install sqlite3`

 - Install CSV - `gem install csv`

## Running the tests

Tests are included in the project under **tests** directory.

To run the tests, go to the project directory and run the file directly.

``` ruby path_to_project/tests/SheetReaderTest.rb```

### Tests explained:

The test sections contains 5 tests set which run over different type of data sets. The data sets has the 5 properties:

	1.) Small data
	2.) Medium size data
	3.) Large Sized data with random numbers.
	4.) Data without end date or nil end date
	5.) Data with only one phone number

Tests while running takes an input file from `test-dataset` section and creates an output file in `result-file ` section.

Once the processing is over, the new created file is compared with an already present correct solution file in `test-dataset`. 
If the calculated result is identical to the correct result, the test is considered to be **passed**, otherwise **failed**.

All the result files created during tests are deleted after the execution.