class DrawsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[ index frequencies ]
  START_TUESDAY_DRAWS_DATE = Date.new(2011, 4, 30)

  def index
    @sort_by = params[:sort_by]
    @draws_by_year = Draw.all.group_by(&:year)
    @years = @draws_by_year.keys.sort.reverse
  end

  def frequencies
    @sort_by    = params.dig(:query, :sort_by) || :number
    @start_date = params.dig(:query, :start).present? ? Date.parse(params.dig(:query, :start)) : Draw.min_date
    @end_date   = params.dig(:query, :end).present? ? Date.parse(params.dig(:query, :end)) : Draw.max_date
    if params[:year].present?
      @year = params[:year].to_i
      @start_date = Date.new(params[:year].to_i, 1, 1)
      @end_date   = Date.new(params[:year].to_i, 12, 31)
    end
    @draws = Draw.where(date: @start_date..@end_date)
    @stats = DrawStats.call @draws, sort_by: @sort_by
  end
end
