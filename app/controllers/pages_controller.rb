class PagesController < ApplicationController
  skip_before_action :authenticate_user! #, only: [:home]

  def home

  end

  def index_per_year
    @array_of_tiragearrays = []
    Tirage.all.each do |tirage_object|
      @array_of_tiragearrays << [tirage_object.date, tirage_object.number1, tirage_object.number2, tirage_object.number3, tirage_object.number4, tirage_object.number5, tirage_object.star1, tirage_object.star2, tirage_object.won_by, tirage_object.prize]
    end

    (2004..2021).to_a.each do |year|
      instance_variable_set("@tirages_#{year}", @array_of_tiragearrays.select { |date, _, _, _, _, _, _, _, _, _| ((Date.parse "#{year}/01/01")...(Date.parse "#{year+1}/01/01")).cover?(date) })
    end
  end

  def frequencies
    @array_of_tiragearrays = []
    Tirage.all.each do |tirage_object|
      @array_of_tiragearrays << [tirage_object.date, tirage_object.number1, tirage_object.number2, tirage_object.number3, tirage_object.number4, tirage_object.number5, tirage_object.star1, tirage_object.star2, tirage_object.won_by, tirage_object.prize]
    end
  end

  def populate
    system 'rails db:seed'
    redirect_to :root
  end
end
