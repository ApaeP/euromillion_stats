class DrawStats
  attr_reader :draws, :draws_count, :numbers, :stars, :starts_at, :ends_at, :lowest_number_frequency, :highest_number_frequency, :sorted

  class << self
    def call(draws = Draw.all, sort_by: nil)
      new(draws, sort_by: sort_by).call
    end
  end

  def initialize(draws, sort_by: nil)
    @draws = draws
    @draws_count = @draws.count
    @sort_by = sort_by
  end

  def call
    @starts_at  = @draws.last.date
    @ends_at    = @draws.first.date
    set_numbers
    set_stars
    sort_data! if @sort_by
    self
  end

  private

    def set_numbers
      @numbers = @draws.map(&:numbers).flatten.group_by(&:itself).transform_values(&:count).sort.to_h
      @lowest_number_frequency = @numbers.values.min
      @highest_number_frequency = @numbers.values.max

      @numbers = @numbers.map { |k, v| NumberStats.new(self, k, v) }
    end

    def set_stars
      @stars = @draws.map(&:stars).flatten.group_by(&:itself).transform_values(&:count).sort.to_h
    end

    def sort_data!
      case @sort_by.to_sym
      when :frequency
        @numbers.sort_by!(&:frequency).reverse!
      when :tuesdays
        @numbers.sort_by!(&:tuesdays).reverse!
      when :fridays
        @numbers.sort_by!(&:fridays).reverse!
      when :number
        @numbers.sort_by!(&:number)
      end
      @sorted = true
    end

    class NumberStats
      attr_reader :draw_stats, :number, :frequency, :percentage, :normalized_percentage, :tuesdays, :fridays

      def initialize(draw_stats, number, frequency)
        @draw_stats = draw_stats
        @number = number
        @frequency = frequency
        @percentage = (@frequency.to_f / @draw_stats.draws_count.to_f * 100).round(2)
        @normalized_percentage = normalize_percentage(frequency, @draw_stats.lowest_number_frequency, @draw_stats.highest_number_frequency)
        @tuesdays = @draw_stats.draws.count { |draw| draw.date.tuesday? && draw.numbers.include?(@number) }
        @fridays = @draw_stats.draws.count { |draw| draw.date.friday? && draw.numbers.include?(@number) }
      end

      private

      def normalize_percentage(base, low, high)
        [0, ((base - low).fdiv(high - low) * 100).round, 100].sort[1]
      end
    end
end
