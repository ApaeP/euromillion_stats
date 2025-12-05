class StarBallComponent < ViewComponent::Base
  SIZES = {
    sm: 'star--sm',
    md: 'star--md',
    lg: 'star--lg',
    xl: 'star--xl'
  }.freeze

  VARIANTS = {
    default: 'star--default',
    hot: 'star--hot',
    cold: 'star--cold',
    muted: 'star--muted'
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
