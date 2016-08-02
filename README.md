# Bond Calculator

## Setup

1. Run `bundle install` from the project root.
2. Run sample usage application using `ruby sample_app.rb` from the project root.
3. To run tests use `rspec --color tests` from the project's root folder.

## Documentation

The project is organized in two main folders: `lib` and `tests`.

The `lib` folder contains the bulk of the application, its re-usable components, while `tests` contains spec files that test various components.

Two files have been created in the `lib` folder for this challenge: `bond_calculator.rb` and `read_file.rb`.

*BondCalculator* class contains various bond calculation and output formatting components and takes in data which is processed from the `data/sample_input.csv` file provided for this exercise.

Currently *BondCalculator* uses data formatted as an array of arrays, or the default output of ruby's CSV parser. The *ReadFile* class can be extended with other data source processors.

### Some Possible Improvement Suggestions

* Make *BondCalculator* less depended on the order of values provided by the *ReadFile* output. I'd make each row a __key, value__ pair, with each item labeled by column name as key. This would eliminate assumptions about value order in the input file. Data coming in from CSV file could also be cleaned up better, especially numerical values. The *BondCalculator* should not have to know how to extract numerical values from the data source, this could be achieved pre-data injection in the instance, or in the *ReadFile* class.
* Inject a formatter object that can be used as a callback, instead of hardcoding the `csv` formatter in the class. This would remove *BondCalculator*'s concern of how output formatting should work.
* Add better exception handling capabilities. Also, the test suite could be improved with more thorough faulty data and side testing.

## Example Usage

```ruby

require_relative "./lib/bond_calculator"
require_relative "./lib/read_file"

DATA_FILE_PATH = File.expand_path("../data/sample_input.csv", __FILE__)
@data = ReadFile.new({file_path: DATA_FILE_PATH}).read_csv

@bond_calculator = BondCalculator.new({data_set: @data, output_formatter: "csv"})

# calculate yield spread
@bond_calculator.return_yield_spread_for({bond_name: "C1"})

# calculate spread to curve
@bond_calculator.return_spread_to_gov_bond_curve_for({bond_name: "C1"})

```
