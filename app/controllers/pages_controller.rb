class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home]

  def home
    @draw_count = Draw.count
    @won_draw_count = Draw.where.not(winners: nil).count
    @won_draw_percentage = (@won_draw_count.to_f / @draw_count.to_f * 100).round(2)
    @winners_count = Draw.where.not(winners: nil).sum(:winners)
  end
end
