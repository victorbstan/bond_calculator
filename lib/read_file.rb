class ReadFile
  require "csv"

  attr_accessor :file_path

  def initialize(args)
    @file_path = args[:file_path]
  end

  def read_csv
    CSV.read(file_path)
  end

end
