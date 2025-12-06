class DrawStats < ApplicationService
  attr_reader :draws,
              :draws_count,
              :numbers,
              :stars,
              :starts_at,
              :ends_at,
              :lowest_number_frequency,
              :highest_number_frequency,
              :lowest_star_frequency,
              :highest_star_frequency,
              :gains,
              :tuesday_gains,
              :friday_gains,
              :winners,
              :tuesday_winners,
              :friday_winners,
              :hot_numbers,
              :cold_numbers,
              :hot_stars,
              :cold_stars,
              :most_overdue_numbers,
              :most_overdue_stars,
              :number_pairs,
              :star_pairs,
              :number_trios,
              :decades_distribution,
              :avg_jackpot,
              :max_jackpot,
              :min_jackpot,
              :biggest_wins,
              :won_draws_count,
              :avg_gap_numbers,
              :avg_gap_stars

  def initialize(draws, sort_by: nil)
    @draws = draws.to_a
    @draws_count = @draws.count
    @sort_by = sort_by
    @sorted_draws = @draws.sort_by(&:date)
  end

  def call
    return self if @draws.empty?

    @starts_at = @sorted_draws.first.date
    @ends_at = @sorted_draws.last.date
    set_numbers
    set_stars
    set_gains
    set_winners
    set_hot_cold_numbers
    set_overdue
    set_pairs_and_trios
    set_decades_distribution
    set_jackpot_stats
    set_biggest_wins
    set_average_gaps
    sort_data! if @sort_by
    self
  end

  private

  def set_numbers
    @numbers = @draws.map(&:numbers).flatten.group_by(&:itself).transform_values(&:count).sort.to_h
    @lowest_number_frequency = @numbers.values.min || 0
    @highest_number_frequency = @numbers.values.max || 0

    @numbers = @numbers.map { |k, v| NumberStats.new(self, k, v) }
  end

  def set_stars
    @stars = @draws.map(&:stars).flatten.group_by(&:itself).transform_values(&:count).sort.to_h
    @lowest_star_frequency = @stars.values.min || 0
    @highest_star_frequency = @stars.values.max || 0

    @stars = @stars.map { |k, v| StarStats.new(self, k, v) }
  end

  def set_gains
    won_draws = @draws.select(&:won?)
    @gains = won_draws.sum(&:prize_amount)
    @tuesday_gains = won_draws.select { |d| d.date.tuesday? }.sum(&:prize_amount)
    @friday_gains = won_draws.select { |d| d.date.friday? }.sum(&:prize_amount)
  end

  def set_winners
    won_draws = @draws.select(&:won?)
    @winners = won_draws.sum(&:winners)
    @tuesday_winners = won_draws.select { |d| d.date.tuesday? }.sum(&:winners)
    @friday_winners = won_draws.select { |d| d.date.friday? }.sum(&:winners)
    @won_draws_count = won_draws.count
  end

  def set_hot_cold_numbers
    sorted_numbers = @numbers.sort_by(&:frequency)
    sorted_stars = @stars.sort_by(&:frequency)

    @hot_numbers = sorted_numbers.last(5).reverse
    @cold_numbers = sorted_numbers.first(5)
    @hot_stars = sorted_stars.last(5).reverse
    @cold_stars = sorted_stars.first(5)
  end

  def set_overdue
    last_draw = @sorted_draws.last
    return if last_draw.nil?

    number_last_seen = {}
    star_last_seen = {}

    @sorted_draws.reverse_each.with_index do |draw, idx|
      draw.numbers.each { |n| number_last_seen[n] ||= idx }
      draw.stars.each { |s| star_last_seen[s] ||= idx }
    end

    (1..50).each { |n| number_last_seen[n] ||= @draws_count }
    (1..12).each { |s| star_last_seen[s] ||= @draws_count }

    @most_overdue_numbers = number_last_seen.sort_by { |_, v| -v }.first(10).map do |num, draws_ago|
      OverdueNumber.new(num, draws_ago, :number)
    end

    @most_overdue_stars = star_last_seen.sort_by { |_, v| -v }.first(5).map do |num, draws_ago|
      OverdueNumber.new(num, draws_ago, :star)
    end
  end

  def set_pairs_and_trios
    number_pairs_count = Hash.new(0)
    star_pairs_count = Hash.new(0)
    number_trios_count = Hash.new(0)

    @draws.each do |draw|
      draw.numbers.combination(2).each do |pair|
        number_pairs_count[pair.sort] += 1
      end

      draw.numbers.combination(3).each do |trio|
        number_trios_count[trio.sort] += 1
      end

      star_pairs_count[draw.stars.sort] += 1
    end

    @number_pairs = number_pairs_count.sort_by { |_, v| -v }.first(10).map do |pair, count|
      Combination.new(pair, count, @draws_count)
    end

    @star_pairs = star_pairs_count.sort_by { |_, v| -v }.first(10).map do |pair, count|
      Combination.new(pair, count, @draws_count)
    end

    @number_trios = number_trios_count.sort_by { |_, v| -v }.first(10).map do |trio, count|
      Combination.new(trio, count, @draws_count)
    end
  end

  def set_decades_distribution
    decades = {
      '1-10' => 0,
      '11-20' => 0,
      '21-30' => 0,
      '31-40' => 0,
      '41-50' => 0
    }

    all_numbers = @draws.flat_map(&:numbers)
    all_numbers.each do |num|
      case num
      when 1..10 then decades['1-10'] += 1
      when 11..20 then decades['11-20'] += 1
      when 21..30 then decades['21-30'] += 1
      when 31..40 then decades['31-40'] += 1
      when 41..50 then decades['41-50'] += 1
      end
    end

    total = all_numbers.count.to_f
    @decades_distribution = decades.map do |range, count|
      DecadeStats.new(range, count, total > 0 ? (count / total * 100).round(2) : 0)
    end
  end

  def set_jackpot_stats
    won_draws = @draws.select(&:won?)
    prizes = won_draws.map(&:prize_amount).reject(&:zero?)

    if prizes.any?
      @avg_jackpot = (prizes.sum.to_f / prizes.count).round
      @max_jackpot = prizes.max
      @min_jackpot = prizes.min
    else
      @avg_jackpot = 0
      @max_jackpot = 0
      @min_jackpot = 0
    end
  end

  def set_biggest_wins
    won_draws = @draws.select(&:won?).sort_by(&:prize_amount).reverse
    @biggest_wins = won_draws.first(5)
  end

  def set_average_gaps
    number_gaps = calculate_gaps(:numbers)
    star_gaps = calculate_gaps(:stars)

    @avg_gap_numbers = number_gaps.transform_values do |gaps|
      gaps.any? ? (gaps.sum.to_f / gaps.count).round(1) : nil
    end

    @avg_gap_stars = star_gaps.transform_values do |gaps|
      gaps.any? ? (gaps.sum.to_f / gaps.count).round(1) : nil
    end
  end

  def calculate_gaps(type)
    gaps = Hash.new { |h, k| h[k] = [] }
    last_seen = {}

    @sorted_draws.each_with_index do |draw, idx|
      elements = draw.send(type)
      elements.each do |elem|
        if last_seen[elem]
          gaps[elem] << (idx - last_seen[elem])
        end
        last_seen[elem] = idx
      end
    end

    gaps
  end

  def sort_data!
    case @sort_by.to_sym
    when :frequency
      @numbers.sort_by!(&:frequency).reverse!
      @stars.sort_by!(&:frequency).reverse!
    when :tuesdays
      @numbers.sort_by!(&:tuesdays).reverse!
      @stars.sort_by!(&:tuesdays).reverse!
    when :fridays
      @numbers.sort_by!(&:fridays).reverse!
      @stars.sort_by!(&:fridays).reverse!
    when :number
      @numbers.sort_by!(&:number)
      @stars.sort_by!(&:number)
    when :overdue
      @numbers.sort_by!(&:draws_since_last).reverse!
      @stars.sort_by!(&:draws_since_last).reverse!
    end
  end

  class Element
    attr_reader :draw_stats, :number, :frequency, :percentage, :normalized_percentage,
                :tuesdays, :fridays, :last_drawn, :draws_since_last, :avg_gap

    def initialize(draw_stats, number, frequency)
      @draw_stats = draw_stats
      @number = number
      @frequency = frequency
      @percentage = draw_stats.draws_count > 0 ? (@frequency.to_f / @draw_stats.draws_count.to_f * 100).round(2) : 0
    end

    private

    def normalize_percentage(base, low, high)
      return 100 if low == high
      [0, ((base - low).fdiv(high - low) * 100).round, 100].sort[1]
    rescue FloatDomainError
      100
    end

    def calculate_draws_since_last(type)
      draws = @draw_stats.instance_variable_get(:@sorted_draws)
      return 0 if draws.empty?

      draws.reverse_each.with_index do |draw, idx|
        return idx if draw.send(type).include?(@number)
      end
      draws.count
    end
  end

  class NumberStats < Element
    def initialize(draw_stats, number, frequency)
      super
      @normalized_percentage = normalize_percentage(frequency, @draw_stats.lowest_number_frequency, @draw_stats.highest_number_frequency)
      @tuesdays = @draw_stats.draws.count { |draw| draw.date.tuesday? && draw.numbers.include?(@number) }
      @fridays = @draw_stats.draws.count { |draw| draw.date.friday? && draw.numbers.include?(@number) }
      @last_drawn = @draw_stats.draws.sort_by(&:date).reverse.find { |draw| draw.numbers.include?(@number) }
      @draws_since_last = calculate_draws_since_last(:numbers)
      @avg_gap = @draw_stats.avg_gap_numbers&.dig(@number)
    end
  end

  class StarStats < Element
    def initialize(draw_stats, number, frequency)
      super
      @normalized_percentage = normalize_percentage(frequency, @draw_stats.lowest_star_frequency, @draw_stats.highest_star_frequency)
      @tuesdays = @draw_stats.draws.count { |draw| draw.date.tuesday? && draw.stars.include?(@number) }
      @fridays = @draw_stats.draws.count { |draw| draw.date.friday? && draw.stars.include?(@number) }
      last_draw = @draw_stats.draws.sort_by(&:date).reverse.find { |draw| draw.stars.include?(@number) }
      @last_drawn = last_draw&.date
      @draws_since_last = calculate_draws_since_last(:stars)
      @avg_gap = @draw_stats.avg_gap_stars&.dig(@number)
    end
  end

  class OverdueNumber
    attr_reader :number, :draws_ago, :type

    def initialize(number, draws_ago, type)
      @number = number
      @draws_ago = draws_ago
      @type = type
    end
  end

  class Combination
    attr_reader :numbers, :count, :percentage

    def initialize(numbers, count, total_draws)
      @numbers = numbers
      @count = count
      @percentage = total_draws > 0 ? (count.to_f / total_draws * 100).round(2) : 0
    end
  end

  class DecadeStats
    attr_reader :range, :count, :percentage

    def initialize(range, count, percentage)
      @range = range
      @count = count
      @percentage = percentage
    end
  end
end
