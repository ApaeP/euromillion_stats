class GridDisplayComponent < ViewComponent::Base
  STRATEGY_LABELS = {
    hot: { icon: '🔥', label: 'Stratégie Chaude', description: 'Numéros les plus fréquents' },
    cold: { icon: '❄️', label: 'Stratégie Froide', description: 'Numéros les moins fréquents' },
    balanced: { icon: '⚖️', label: 'Équilibrée', description: 'Mix équilibré' },
    random: { icon: '🎲', label: 'Aléatoire', description: 'Sélection au hasard' },
    overdue: { icon: '⏰', label: 'En Retard', description: 'Numéros absents depuis longtemps' }
  }.freeze

  def initialize(grid:)
    @grid = grid
    @strategy_info = STRATEGY_LABELS[grid.strategy] || STRATEGY_LABELS[:balanced]
  end

  private

  attr_reader :grid, :strategy_info
end
