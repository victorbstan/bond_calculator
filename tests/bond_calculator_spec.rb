require_relative "../lib/bond_calculator"
require_relative "../lib/read_file"

DATA_FILE_PATH = File.expand_path("../../data/sample_input.csv", __FILE__)

RSpec.describe BondCalculator do
  before do
    @data = ReadFile.new({file_path: DATA_FILE_PATH}).read_csv
    @bond_calculator = BondCalculator.new({data_set: @data, output_formatter: "csv"})
  end

  context "with data set" do
    it "calculate multiple yield spreads; (return) between a corporate bond and its government bond benchtmark" do
      yield_spreads = @bond_calculator.return_all_yield_spreads
      expect(yield_spreads).to eq("bond,benchmark,spread_to_benchmark\nC1,G1,1.60%\nC2,G2,1.50%\nC3,G3,2.00%\nC4,G3,2.90%\nC5,G4,0.90%\nC6,G5,1.80%\nC7,G6,2.50%\n")
    end

    it "calculates single yield spread; (return) between a corporate bond and its government bond benchtmark" do
      yield_spread = @bond_calculator.return_yield_spread_for({bond_name: "C1"})
      expect(yield_spread).to eq("bond,benchmark,spread_to_benchmark\nC1,G1,1.60%\n")
    end

    it "calculates government benchmark to corporate bond" do
      years_to_maturity = 10.5
      expect(
        @bond_calculator.get_gov_bond_benchmark({
          corp_bond_years_to_maturity: years_to_maturity
        })
      ).to eq(["G4", "government", "12 years", "5.50%"])
    end

    it "filters government bonds out of date set" do
      gov_bonds = @bond_calculator.gov_bonds_set

      expect(gov_bonds.length).to eq(6)
      expect(gov_bonds.map {|row| row[1]}.uniq).to eq(["government"])
    end

    it "filters corporate bonds out of data set" do
      corp_bonds = @bond_calculator.corp_bonds_set

      expect(corp_bonds.length).to eq(7)
      expect(corp_bonds.map {|row| row[1]}.uniq).to eq(["corporate"])
    end

    it "calculates yield spread for corp data" do
      corp_data = ["C1", "corporate", "1.3 years", "3.30%"]

      result = @bond_calculator.calculate_yield_spread_for({corp_data: corp_data})
      expect(result).to eq(["C1", "G1", "1.60%"])
    end

    it "gets two nearest government bonds given a corporate bond" do
      corp_data = ["C1", "corporate", "1.3 years", "3.30%"]
      result = @bond_calculator.calculate_neighbour_gov_bonds_for({corp_data: corp_data})
      expect(result).to eq({
        smaller: ["G1", "government", "0.9 years", "1.70%"],
        greater: ["G2", "government", "2.3 years", "2.30%"]
      })

      corp_data_2 = ["C3", "corporate" , "5.2 years" , "5.30%"]
      result = @bond_calculator.calculate_neighbour_gov_bonds_for({corp_data: corp_data_2})
      expect(result).to eq({
        smaller: ["G2", "government", "2.3 years", "2.30%"],
        greater: ["G3", "government", "7.8 years", "3.30%"]
      })
    end

    it "calculates spread to the curve for given corp bond" do
      corp_data = ["C1", "corporate", "1.3 years", "3.30%"]
      result = @bond_calculator.calculate_spread_to_gov_bond_curve_for({corp_data: corp_data})
      expect(result).to eq(1.43)

      corp_data_2 = ["C3", "corporate" , "5.2 years" , "5.30%"]
      result = @bond_calculator.calculate_spread_to_gov_bond_curve_for({corp_data: corp_data_2})
      expect(result).to eq(2.47)
    end

    it "returns formatted result for spread to the curve calculation for given corp bond" do
      bond_name = "C1"
      result = @bond_calculator.return_spread_to_gov_bond_curve_for({bond_name: "C1"})
      expect(result).to eq("bond,spread_to_curve\nC1,1.43%\n")
    end
  end
end
