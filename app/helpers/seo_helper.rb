module SeoHelper
  def page_title(title = nil)
    base = "EuroStats"
    title.present? ? "#{title} | #{base}" : "#{base} - Statistiques EuroMillions"
  end

  def page_description(description = nil)
    description || "Analysez les statistiques des tirages EuroMillions : numéros chauds et froids, fréquences, paires gagnantes, générateur de grilles intelligent. Données mises à jour régulièrement."
  end

  def page_keywords
    "euromillions, statistiques, loto, tirage, numéros gagnants, fréquence, analyse, générateur grille, numéros chauds, numéros froids, jackpot, résultats"
  end

  def canonical_url
    request.original_url.split('?').first
  end

  def og_type
    "website"
  end

  def og_image
    asset_url("logo.png")
  rescue
    "https://eurostats.app/logo.png"
  end

  def twitter_card
    "summary_large_image"
  end

  def seo_meta_tags(title: nil, description: nil, image: nil, type: nil)
    safe_join([
      tag.meta(name: "description", content: page_description(description)),
      tag.meta(name: "keywords", content: page_keywords),
      tag.meta(name: "author", content: "EuroStats"),
      tag.meta(name: "robots", content: "index, follow"),
      tag.link(rel: "canonical", href: canonical_url),

      tag.meta(property: "og:type", content: type || og_type),
      tag.meta(property: "og:title", content: page_title(title)),
      tag.meta(property: "og:description", content: page_description(description)),
      tag.meta(property: "og:url", content: canonical_url),
      tag.meta(property: "og:image", content: image || og_image),
      tag.meta(property: "og:site_name", content: "EuroStats"),
      tag.meta(property: "og:locale", content: I18n.locale == :fr ? "fr_FR" : "en_US"),

      tag.meta(name: "twitter:card", content: twitter_card),
      tag.meta(name: "twitter:title", content: page_title(title)),
      tag.meta(name: "twitter:description", content: page_description(description)),
      tag.meta(name: "twitter:image", content: image || og_image),

      tag.meta(name: "theme-color", content: "#1a2744"),
      tag.meta(name: "msapplication-TileColor", content: "#1a2744"),
    ], "\n")
  end

  def json_ld_website
    {
      "@context": "https://schema.org",
      "@type": "WebSite",
      "name": "EuroStats",
      "url": root_url,
      "description": page_description,
      "potentialAction": {
        "@type": "SearchAction",
        "target": "#{frequencies_draws_url}?year={search_term_string}",
        "query-input": "required name=search_term_string"
      }
    }.to_json
  end

  def json_ld_organization
    {
      "@context": "https://schema.org",
      "@type": "Organization",
      "name": "EuroStats",
      "url": root_url,
      "logo": og_image,
      "sameAs": []
    }.to_json
  end

  def json_ld_breadcrumbs(items)
    {
      "@context": "https://schema.org",
      "@type": "BreadcrumbList",
      "itemListElement": items.each_with_index.map do |item, index|
        {
          "@type": "ListItem",
          "position": index + 1,
          "name": item[:name],
          "item": item[:url]
        }
      end
    }.to_json
  end

  def json_ld_lottery_stats(stats)
    {
      "@context": "https://schema.org",
      "@type": "Dataset",
      "name": "Statistiques EuroMillions",
      "description": "Analyse statistique des tirages EuroMillions",
      "url": frequencies_draws_url,
      "creator": {
        "@type": "Organization",
        "name": "EuroStats"
      },
      "temporalCoverage": "#{stats.starts_at&.iso8601}/#{stats.ends_at&.iso8601}",
      "variableMeasured": [
        { "@type": "PropertyValue", "name": "Nombre de tirages", "value": stats.draws_count },
        { "@type": "PropertyValue", "name": "Gains totaux", "value": stats.gains, "unitCode": "EUR" },
        { "@type": "PropertyValue", "name": "Nombre de gagnants", "value": stats.winners }
      ]
    }.to_json
  end
end

