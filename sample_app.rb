require_relative "./lib/bond_calculator"
require_relative "./lib/read_file"

# Example usage

DATA_FILE_PATH = File.expand_path("../data/sample_input.csv", __FILE__)

@data = ReadFile.new({file_path: DATA_FILE_PATH}).read_csv
@bond_calculator = BondCalculator.new({data_set: @data, output_formatter: "csv"})

# Example output

puts "CHALLENGE 1"
puts "Single yield spread calculation:\n\n"
puts @bond_calculator.return_yield_spread_for({bond_name: "C1"})

puts "\n\n"

puts "All yield spread calculations:\n\n"
puts @bond_calculator.return_all_yield_spreads

puts "\n\n"

puts "CHALLENGE 2"
puts "Spread to curve calculation for given corporate bond\n\n"
puts @bond_calculator.return_spread_to_gov_bond_curve_for({bond_name: "C1"})
