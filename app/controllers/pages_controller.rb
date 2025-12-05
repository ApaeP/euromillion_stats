class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home]

  def home
    @draw_count = Draw.count
    @won_draw_count = Draw.won.count
    @won_draw_percentage = @draw_count > 0 ? (@won_draw_count.to_f / @draw_count.to_f * 100).round(2) : 0
    @winners_count = Draw.won.sum(:winners)
    @last_draw = Draw.order(date: :desc).first
  end
end
