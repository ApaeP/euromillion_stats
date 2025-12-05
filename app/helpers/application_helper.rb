module ApplicationHelper
  def color_level(percentage, color: :primary)
    coef = [0, [percentage.to_f / 100, 1].min].max

    case color
    when :primary
      low = "74B9FF"
      high = "0082B3"
    when :info
      low = "FFE082"
      high = "F4B400"
    when :hot
      low = "FFA8A8"
      high = "E53935"
    when :cold
      low = "90CAF9"
      high = "1565C0"
    end

    interpolate_color(low, high, coef)
  end

  def display_prize(prize)
    return "Non communiqué" if prize.nil? || prize.zero?

    number_to_currency(prize, unit: "€", separator: ",", delimiter: " ", format: "%n %u", precision: 0, locale: :fr)
  end

  private

  def interpolate_color(low_hex, high_hex, coef)
    low_r, low_g, low_b = low_hex.scan(/.{2}/).map { |e| e.to_i(16) }
    high_r, high_g, high_b = high_hex.scan(/.{2}/).map { |e| e.to_i(16) }

    r = (low_r + ((high_r - low_r) * coef)).round.clamp(0, 255)
    g = (low_g + ((high_g - low_g) * coef)).round.clamp(0, 255)
    b = (low_b + ((high_b - low_b) * coef)).round.clamp(0, 255)

    "##{r.to_s(16).rjust(2, '0')}#{g.to_s(16).rjust(2, '0')}#{b.to_s(16).rjust(2, '0')}".upcase
  end
end
