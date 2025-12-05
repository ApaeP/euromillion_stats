class NumberBallComponent < ViewComponent::Base
  SIZES = {
    sm: 'ball--sm',
    md: 'ball--md',
    lg: 'ball--lg',
    xl: 'ball--xl'
  }.freeze

  VARIANTS = {
    default: 'ball--number',
    hot: 'ball--hot',
    cold: 'ball--cold',
    muted: 'ball--muted'
  }.freeze

  def initialize(number:, size: :md, variant: :default, tooltip: nil, show_frequency: false, frequency: nil)
    @number = number
    @size = SIZES[size] || SIZES[:md]
    @variant = VARIANTS[variant] || VARIANTS[:default]
    @tooltip = tooltip
    @show_frequency = show_frequency
    @frequency = frequency
  end

  private

  attr_reader :number, :size, :variant, :tooltip, :show_frequency, :frequency
end
