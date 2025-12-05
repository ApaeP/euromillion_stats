class SectionCardComponent < ViewComponent::Base
  VARIANTS = {
    default: { bg: 'primary', text: 'text-white' },
    navy: { bg: 'primary', text: 'text-white' },
    gold: { bg: 'warning', text: 'text-dark' },
    sky: { bg: 'info', text: 'text-white' },
    hot: { bg: 'danger', text: 'text-white' },
    cold: { bg: 'info', text: 'text-white' },
    dark: { bg: 'dark', text: 'text-white' }
  }.freeze

  def initialize(title:, subtitle: nil, variant: :default, icon: nil)
    @title = title
    @subtitle = subtitle
    @variant = variant
    @icon = icon
  end

  def variant_class
    VARIANTS.dig(@variant, :bg) || 'primary'
  end

  def text_class
    VARIANTS.dig(@variant, :text) || 'text-white'
  end

  private

  attr_reader :title, :subtitle, :icon
end
