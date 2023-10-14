require 'open-uri'

module Scrapers
  class DrawGenerator
    class << self
      def call
        draw_count = 0
        (2004..Date.today.year).to_a.each do |year|
          url = "https://www.tirage-euromillions.net/euromillions/annees/annee-#{year}/"
          Nokogiri::HTML(open(url).read).search('tr').reverse.each do |row|
            next if row.search('td').count < 10

            values = row.search('td').map { |e| e.text.strip }
            draw = Draw.create(
              date: Date.parse(values[0].split[1]),
              number1: values[1].to_i,
              number2: values[2].to_i,
              number3: values[3].to_i,
              number4: values[4].to_i,
              number5: values[5].to_i,
              star1: values[6].to_i,
              star2: values[7].to_i,
              won_by: values[8].to_i > 0 ? values[8].to_i : nil,
              prize: values[9]
            )
          end
        end
      end
    end
  end
end
