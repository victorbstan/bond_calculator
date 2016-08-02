class BondCalculator
  attr_accessor :data_set, :output_formatter

  def initialize(args)
    @data_set = args[:data_set]
    @data_set.shift # skip first row, it's just column headings

    @output_formatter = args[:output_formatter]
  end

  def return_all_yield_spreads
    result = corp_bonds_set.map do |corp_data|
      calculate_yield_spread_for({corp_data: corp_data})
    end

    format_yield_spreads({yield_spreads: result})
  end

  def return_yield_spread_for(args)
    bond_name = args[:bond_name]

    corp_data = corp_bonds_set.find do |corp_bond|
      corp_bond[0] == bond_name
    end

    result = calculate_yield_spread_for({corp_data: corp_data})

    format_yield_spreads({yield_spread: result})
  end

  def calculate_yield_spread_for(args)
    corp_data = args[:corp_data]
    corp_term = corp_data[2].split(' ')[0].to_f

    gov_benchmark = get_gov_bond_benchmark({corp_bond_years_to_maturity: corp_term})

    spread = spread_to_benchmark({
      corp_yield: corp_data[3].to_f,
      gov_yield: gov_benchmark[3].to_f
    })

    result = [corp_data[0], gov_benchmark[0], "#{"%.2f" % spread}%"]

    result
  end

  def format_yield_spreads(args)
    heading = ["bond", "benchmark", "spread_to_benchmark"]

    # multiple
    yield_spreads = args[:yield_spreads]
    # single
    yield_spread = args[:yield_spread]

    if (yield_spreads)
      fromatted_result = yield_spreads
      fromatted_result.unshift(heading)
    else
      fromatted_result = [
        heading,
        yield_spread
      ]
    end

    if output_formatter == "csv"
      fromatted_result.map(&:to_csv).join
    else
      fromatted_result
    end
  end

  def get_gov_bond_benchmark(args)
    corp_bond_years_to_maturity = args[:corp_bond_years_to_maturity]

    gov_bonds_set.min_by do |v|
      v = v[2].split(' ')[0].to_f if v
      (v - corp_bond_years_to_maturity).abs
    end
  end

  def gov_bonds_set
    data_set.select do |row|
      row[1] == "government" ? true : false
    end
  end

  def corp_bonds_set
    data_set.select do |row|
      row[1] == "corporate" ? true : false
    end
  end

  def spread_to_benchmark(args)
    gov_yield = args[:gov_yield]
    corp_yield = args[:corp_yield]

    (corp_yield - gov_yield).round(2)
  end

  def calculate_neighbour_gov_bonds_for(args)
    corp_data = args[:corp_data]
    corp_bond_term = corp_data[2].split(' ')[0].to_f

    smaller_gov_bonds = []
    greater_gov_bonds = []

    gov_bonds_set.each do |gov_bond|
      gov_bond_term = gov_bond[2].split(' ')[0].to_f

      smaller_gov_bonds << gov_bond if gov_bond_term < corp_bond_term
      greater_gov_bonds << gov_bond if gov_bond_term > corp_bond_term
    end

    # pic one of the set
    smaller_gov_bond = smaller_gov_bonds.max
    greater_gov_bond = greater_gov_bonds.min

    # format return value
    {
      smaller: smaller_gov_bond,
      greater: greater_gov_bond
    }
  end

  def calculate_spread_to_gov_bond_curve_for(args)
    corp_data = args[:corp_data]

    # extract data

    corp_bond_yield = corp_data[3].to_f
    corp_bond_term = corp_data[2].split(' ')[0].to_f

    gov_bond_neighbours = calculate_neighbour_gov_bonds_for({corp_data: corp_data})

    smaller_gov_bond_term = gov_bond_neighbours[:smaller][2].split(' ')[0].to_f
    greater_gov_bond_term = gov_bond_neighbours[:greater][2].split(' ')[0].to_f

    smaller_gov_bond_yield = gov_bond_neighbours[:smaller][3].to_f
    greater_gov_bond_yield = gov_bond_neighbours[:greater][3].to_f

    # prepare vars for algo

    c_yield = corp_bond_yield
    c_term = corp_bond_term

    g1_yield = smaller_gov_bond_yield
    g2_yield = greater_gov_bond_yield

    g1_term = smaller_gov_bond_term
    g2_term = greater_gov_bond_term

    # find interpolated yield
    interpolated_yield = (g1_yield +
                         (
                           (c_term - g1_term) *
                           (
                             (g2_yield - g1_yield) /
                             (g2_term - g1_term)
                           )
                         )).round(2)

    spread_to_curve = (c_yield - interpolated_yield).round(2)
  end

  def return_spread_to_gov_bond_curve_for(args)
    bond_name = args[:bond_name]

    corp_data = corp_bonds_set.find do |corp_bond|
      corp_bond[0] == bond_name
    end

    result = calculate_spread_to_gov_bond_curve_for({corp_data: corp_data})

    heading = ["bond", "spread_to_curve"]

    fromatted_result = [
      heading,
      [corp_data[0], "#{"%.2f" % result}%"]
    ]

    if output_formatter == "csv"
      fromatted_result.map(&:to_csv).join
    else
      fromatted_result
    end
  end

end
