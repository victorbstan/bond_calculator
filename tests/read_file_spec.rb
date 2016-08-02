require_relative "../lib/read_file"

CORRECT_DATA_FILE_PATH = File.expand_path("../../data/sample_input.csv", __FILE__)

RSpec.describe ReadFile, "#read_csv" do
  context "with correct file path" do
    it "reads file data into array of arrays" do
      data = ReadFile.new({file_path: CORRECT_DATA_FILE_PATH}).read_csv
      expect(data.length).to eq(14)
    end
  end
end
