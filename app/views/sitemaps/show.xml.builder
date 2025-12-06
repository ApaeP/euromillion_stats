xml.instruct! :xml, version: "1.0", encoding: "UTF-8"
xml.urlset xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9" do
  # Homepage - highest priority
  xml.url do
    xml.loc root_url
    xml.lastmod Time.current.strftime("%Y-%m-%d")
    xml.changefreq "daily"
    xml.priority 1.0
  end

  # Statistics page - high priority, updates with every draw
  xml.url do
    xml.loc frequencies_draws_url
    xml.lastmod Draw.maximum(:date)&.strftime("%Y-%m-%d") || Time.current.strftime("%Y-%m-%d")
    xml.changefreq "weekly"
    xml.priority 0.9
  end

  # Results page
  xml.url do
    xml.loc draws_url
    xml.lastmod Draw.maximum(:date)&.strftime("%Y-%m-%d") || Time.current.strftime("%Y-%m-%d")
    xml.changefreq "weekly"
    xml.priority 0.8
  end

  # Statistics pages per year
  Draw.pluck(:date).map(&:year).uniq.sort.reverse.each do |year|
    xml.url do
      xml.loc frequencies_draws_url(year: year)
      xml.lastmod Draw.where("EXTRACT(year FROM date) = ?", year).maximum(:date)&.strftime("%Y-%m-%d")
      xml.changefreq year == Date.current.year ? "weekly" : "yearly"
      xml.priority 0.7
    end
  end
end

