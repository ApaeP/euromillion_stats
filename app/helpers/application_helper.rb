module ApplicationHelper

  def color_level(percentage, color: :primary)
    coef = percentage.fdiv(100)
    case color
    when :primary
      low, high = "99A3CC", "001367"
    when :info
      low, high = "FFE17F", "EEBB05"
    end
    # low, high = "99A3CC", "001367"
    # low, high = "FFEDB2", "EEBB05"

    low_red, low_green, low_blue = low.scan(/.{2}/).map { |e| e.to_i(16) }
    high_red, high_green, high_blue = high.scan(/.{2}/).map { |e| e.to_i(16) }
    validate_double_chars = ->(str) { str.size < 2 ? "0#{str}" : str }

    r = validate_double_chars.call((low_red + ((high_red - low_red) * coef).round).to_s(16))
    g = validate_double_chars.call((low_green + ((high_green - low_green) * coef).round).to_s(16))
    b = validate_double_chars.call((low_blue + ((high_blue - low_blue) * coef).round).to_s(16))

    "##{r}#{g}#{b}".upcase
  end
end
