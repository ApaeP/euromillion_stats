class GridGenerator < ApplicationService
  STRATEGIES = %i[hot cold balanced random overdue].freeze

  attr_reader :numbers, :stars, :strategy

  def initialize(stats, strategy: :balanced)
    @stats = stats
    @strategy = strategy.to_sym
  end

  def call
    @numbers = generate_numbers
    @stars = generate_stars
    self
  end

  def to_s
    "#{@numbers.sort.join(' - ')} | ⭐ #{@stars.sort.join(' - ')}"
  end

  def to_h
    { numbers: @numbers.sort, stars: @stars.sort, strategy: @strategy }
  end

  private

  def generate_numbers
    case @strategy
    when :hot
      pick_from_weighted(@stats.numbers.sort_by(&:frequency).reverse, 5, :numbers)
    when :cold
      pick_from_weighted(@stats.numbers.sort_by(&:frequency), 5, :numbers)
    when :overdue
      pick_from_weighted(@stats.numbers.sort_by(&:draws_since_last).reverse, 5, :numbers)
    when :balanced
      generate_balanced_numbers
    when :random
      (1..50).to_a.sample(5)
    else
      (1..50).to_a.sample(5)
    end
  end

  def generate_stars
    case @strategy
    when :hot
      pick_from_weighted(@stats.stars.sort_by(&:frequency).reverse, 2, :stars)
    when :cold
      pick_from_weighted(@stats.stars.sort_by(&:frequency), 2, :stars)
    when :overdue
      pick_from_weighted(@stats.stars.sort_by(&:draws_since_last).reverse, 2, :stars)
    when :balanced
      generate_balanced_stars
    when :random
      (1..12).to_a.sample(2)
    else
      (1..12).to_a.sample(2)
    end
  end

  def pick_from_weighted(sorted_elements, count, type)
    pool_size = [sorted_elements.size, count * 3].min
    pool = sorted_elements.first(pool_size)

    weights = pool.each_with_index.map { |_, i| pool_size - i }
    # total_weight = weights.sum

    selected = []
    available = pool.dup
    available_weights = weights.dup

    count.times do
      break if available.empty?

      rand_val = rand(available_weights.sum)
      cumulative = 0
      idx = 0

      available_weights.each_with_index do |w, i|
        cumulative += w
        if rand_val < cumulative
          idx = i
          break
        end
      end

      selected << available[idx].number
      available.delete_at(idx)
      available_weights.delete_at(idx)
    end

    selected
  end

  def generate_balanced_numbers
    sorted = @stats.numbers.sort_by(&:frequency)

    hot = sorted.last(15)
    cold = sorted.first(15)
    middle = sorted[15..34] || []

    selected = []

    selected += hot.sample(2).map(&:number)

    cold_pick = (cold - selected.map { |n| cold.find { |c| c.number == n } }).sample(1)
    selected += cold_pick.map(&:number)

    remaining = (middle - selected.map { |n| middle.find { |m| m&.number == n } }).compact
    remaining = sorted.reject { |s| selected.include?(s.number) } if remaining.size < 2
    selected += remaining.sample(2).map(&:number)

    selected.uniq.first(5)
  end

  def generate_balanced_stars
    sorted = @stats.stars.sort_by(&:frequency)

    top_half = sorted.last(6)
    bottom_half = sorted.first(6)

    selected = []
    selected << top_half.sample.number
    remaining = bottom_half.reject { |s| s.number == selected.first }
    selected << remaining.sample.number

    selected
  end
end

