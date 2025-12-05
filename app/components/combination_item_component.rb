class CombinationItemComponent < ViewComponent::Base
  def initialize(combination:, rank: nil, type: :numbers)
    @combination = combination
    @rank = rank
    @type = type
  end

  private

  attr_reader :combination, :rank, :type

  def numbers?
    type == :numbers
  end
end
