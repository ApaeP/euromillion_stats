# frozen_string_literal: true

class StatsCardComponent < ViewComponent::Base
  include ApplicationHelper
  attr_reader :draws, :stats

  def initialize(draws = Draw.all, sort_by: nil)
    @draws = draws
    @sort_by = sort_by
    @stats = set_stats
  end

  def set_stats
    DrawStats.call @draws, sort_by: @sort_by
  end
end
