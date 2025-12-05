class StatCardComponent < ViewComponent::Base
  def initialize(value:, label:, variant: :default, icon: nil, tooltip: nil)
    @value = value
    @label = label
    @variant = variant
    @icon = icon
    @tooltip = tooltip
  end

  private

  attr_reader :value, :label, :variant, :icon, :tooltip
end
