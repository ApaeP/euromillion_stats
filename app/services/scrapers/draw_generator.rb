require 'open-uri'

module Scrapers
  class DrawGenerator
    class << self
      def call
        draw_count = 0
        start_year = Draw.any? ? Draw.max_date.year : Draw.min_date.year
        (start_year..Date.today.year).to_a.each do |year|
          url = "https://www.tirage-euromillions.net/euromillions/annees/annee-#{year}/"
          nokodoc = Nokogiri::HTML(open(url).read)
          nokodoc.search('tr').reverse.each do |row|
            next if row.search('td').count < 10

            values = row.search('td').map { |e| e.text.strip }
            draw_data = {
              date: Date.parse(values[0].split[1]),
              number1: values[1].to_i,
              number2: values[2].to_i,
              number3: values[3].to_i,
              number4: values[4].to_i,
              number5: values[5].to_i,
              star1: values[6].to_i,
              star2: values[7].to_i,
              winners: values[8].to_i,
              prize: values[9]
            }
            Draw.create(draw_data)
          end
        end
      end
    end
  end
end
