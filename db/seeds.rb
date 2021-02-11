puts "\n\nSEEDING STARTING"

puts "\nCleaning DB"
  Tirage.destroy_all
puts "\nDB Cleaned"

# Création des instances d'objet Year de 2004 à l'année courante
# lien_pages = []
# (2004..Date.today.year).to_a.each { |annee| lien_pages << "http://www.tirage-euromillions.net/euromillions/annees/annee-#{annee}/" }

puts "\n Création des années"
  (2004..Date.today.year).to_a.each { |annee| Year.create!(year: annee, url: "http://www.tirage-euromillions.net/euromillions/annees/annee-#{annee}/") }
puts "Années crées\n "

# Instanciations des variables générales
ARRAY_DE_TABLEAUX_DE_RESULTATS = []
ARRAY_DE_CHIFFRES_GAGNANTS = []
ARRAY_DES_ETOILES_GAGNANTES = []


tirage_count = 0
Year.all.each do |year|
  Nokogiri::HTML(open(year.url).read).search('tr').reverse.each do |row|
    row.search('td').each_with_index do |elem, i|
      tirage = Tirage.new
      case i
        when 0 #Date
          p elem.text.split[1]
          tirage.date = Date.parse elem.text.split[1]
        when 1
          p elem.text.strip.to_i
          tirage.number1 = elem.text.strip.to_i
        when 2
          p elem.text.strip.to_i
          tirage.number2 = elem.text.strip.to_i
        when 3
          p elem.text.strip.to_i
          tirage.number3 = elem.text.strip.to_i
        when 4
          p elem.text.strip.to_i
          tirage.number4 = elem.text.strip.to_i
        when 5
          p elem.text.strip.to_i
          tirage.number5 = elem.text.strip.to_i
        when 6
          p elem.text.strip.to_i
          tirage.star1 = elem.text.strip.to_i
        when 7
          p elem.text.strip.to_i
          tirage.star2 = elem.text.strip.to_i
        when 8
          p elem.text.strip.to_i
          elem.text.strip.to_i > 0 ? (tirage.won_by = elem.text.strip.to_i) : (tirage.won_by = nil)
        when 9
          p elem.text
          tirage.prize = elem.text
      end
      tirage.year = year
      tirage.save!
      puts "Tirage n°#{tirage_count} crée"
      tirage_count += 1
    end
  end
end


# Ici est construit :
#   1°) Un tableau de tableaux triés par date et qui contiennent :
#       [ DATE_DU_TIRAGE_PARSEE , CHIFFRE1 , CHIFFRE2 , CHIFFRE3 , CHIFFRE4 , CHIFFRE5 , ETOILE1 , ETOILE2, NOMBRE DE GAGNANTS, MONTANT_A_GAGNER_OU_GAGNE ]
#   2°) Un tableau de tous les chiffres gagnants
#   3°) Un tableau de toutes les étoiles gagnantes
# puts "\nCreating tirages"
# Year.all.each do |year|
#   i = 1
#   # Lire le document HTML
#   html_doc = Nokogiri::HTML(open(year.url).read)
#   # Dans chaque page, chercher l'element contenant le tableau à parser, recuperer un array de tous les rangs du tableaux, l'inverser pour mettre les dates dans l'ordre, puis iterer sur ces rangs (n°1)
#   html_doc.search('#tiragesAnnee').search('tr').reverse.each do |row|
#     # Instanciation d'un array qui correspondra a la construction n°1 établie ci-dessus
#     one_result_array = []
#     # itération sur les éléments td du rang afin de remplir l'array instancié directement ci-dessus
#     row.search('td').each_with_index do |chiffre, i|
#       # Trier les éléments dans l'ordre et pour en faire des objets lisibles (integers and strings)

#       case i # IV
#         when 0
#           unless chiffre.text.split[1].length < 5 # V
#             one_result_array << (Date.parse chiffre.text.split[1])
#           end # V
#         when 1..5
#           ARRAY_DE_CHIFFRES_GAGNANTS << chiffre.text.strip.to_i
#           one_result_array << chiffre.text.strip.to_i
#         when 6..7
#           ARRAY_DES_ETOILES_GAGNANTES << chiffre.text.strip.to_i
#           one_result_array << chiffre.text.strip.to_i
#         when 8
#           if chiffre.text.strip.to_i == 0
#             one_result_array << nil
#           else
#             one_result_array << chiffre.text.strip.to_i
#           end
#         when 9
#           one_result_array << chiffre.text
#       end # IV
#     end # row.search('td').each_with_index do |chiffre, i|
#     unless one_result_array.length < 10 || one_result_array == nil || one_result_array.include?(0) || one_result_array == []
#       ARRAY_DE_TABLEAUX_DE_RESULTATS << one_result_array
#       puts "Tirage n°#{i} created"
#     end # unless one_result_array.length < 9 || one_result_array == nil || one_result_array.include?(0)
#       i += 1
#   end # html_doc.search('#tiragesAnnee').search('tr').reverse.each do |row|
# end
# puts "\nTirages created"

# ARRAY_DE_TABLEAUX_DE_RESULTATS.each do |e|
#   Tirage.create!(date: e[0], number1: e[1], number2: e[2], number3: e[3], number4: e[4], number5: e[5], star1: e[6], star2: e[7], won_by: e[8], prize: e[9] )
# end

puts "\n\nSEEDING ENDED"
