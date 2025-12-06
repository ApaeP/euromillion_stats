require 'csv'
require 'open-uri'

class CsvDrawImporter < ApplicationService
  STATIC_FILES = [
    'db/seeds/files/euromillions_2004_02__2011_05.csv',
    'db/seeds/files/euromillions_2011_05__2014_01.csv',
    'db/seeds/files/euromillions_2014_02__2016_11.csv',
    'db/seeds/files/euromillions_2016_09__2019_02.csv',
    'db/seeds/files/euromillions_2019_03__2020_01.csv'
  ].freeze

  FDJ_LATEST_URL = 'https://www.sto.api.fdj.fr/anonymous/service-draw-info/v3/documentations/1a2b3c4d-9876-4562-b3fc-2c963f66afe6'.freeze

  def initialize(use_remote_latest: false)
    @use_remote_latest = use_remote_latest
  end

  def call
    imported_count = 0
    existing_dates = Draw.pluck(:date).to_set

    STATIC_FILES.each do |file_path|
      next unless File.exist?(file_path)

      puts "  Importing #{File.basename(file_path)}..."
      count = import_file(file_path, existing_dates)
      imported_count += count
      puts "    -> #{count} draws imported"
    end

    if @use_remote_latest
      puts "  Downloading latest data from FDJ..."
      count = import_from_remote(existing_dates)
      imported_count += count
      puts "    -> #{count} draws imported"
    else
      local_latest = 'db/seeds/files/euromillions_2020_02__2025_12.csv'
      if File.exist?(local_latest)
        puts "  Importing #{File.basename(local_latest)}..."
        count = import_file(local_latest, existing_dates)
        imported_count += count
        puts "    -> #{count} draws imported"
      end
    end

    imported_count
  end

  private

  def import_file(file_path, existing_dates)
    content = File.read(file_path, encoding: 'ISO-8859-1:UTF-8')
    import_csv_content(content, existing_dates)
  end

  def import_from_remote(existing_dates)
    require 'zip'

    tempfile = URI.open(FDJ_LATEST_URL)

    Zip::File.open_buffer(tempfile) do |zip_file|
      csv_entry = zip_file.find { |entry| entry.name.end_with?('.csv') }
      return 0 unless csv_entry

      content = csv_entry.get_input_stream.read.force_encoding('ISO-8859-1').encode('UTF-8')
      return import_csv_content(content, existing_dates)
    end
  rescue LoadError
    puts "    rubyzip gem not installed. Run: bundle add rubyzip"
    puts "    Falling back to local file..."
    fallback_to_local(existing_dates)
  rescue StandardError => e
    puts "    Error downloading from FDJ: #{e.message}"
    puts "    Falling back to local file..."
    fallback_to_local(existing_dates)
  end

  def fallback_to_local(existing_dates)
    local_latest = 'db/seeds/files/euromillions_2020_02__2025_12.csv'
    return import_file(local_latest, existing_dates) if File.exist?(local_latest)

    0
  end

  def import_csv_content(content, existing_dates)
    imported = 0

    CSV.parse(content, col_sep: ';', headers: true) do |row|
      draw_data = parse_row(row)
      next unless draw_data
      next if existing_dates.include?(draw_data[:date])

      Draw.create!(draw_data)
      existing_dates.add(draw_data[:date])
      imported += 1
    rescue ActiveRecord::RecordInvalid => e
      puts "      Skipping invalid row: #{e.message}"
    end

    imported
  end

  def parse_row(row)
    date = parse_date(row['date_de_tirage'])
    return nil unless date

    numbers = [
      row['boule_1']&.to_i,
      row['boule_2']&.to_i,
      row['boule_3']&.to_i,
      row['boule_4']&.to_i,
      row['boule_5']&.to_i
    ]

    stars = [
      row['etoile_1']&.to_i,
      row['etoile_2']&.to_i
    ]

    return nil if numbers.any?(&:nil?) || numbers.any?(&:zero?)
    return nil if stars.any?(&:nil?) || stars.any?(&:zero?)

    winners = extract_winners(row)
    prize = extract_prize(row)

    {
      date: date,
      number1: numbers[0],
      number2: numbers[1],
      number3: numbers[2],
      number4: numbers[3],
      number5: numbers[4],
      star1: stars[0],
      star2: stars[1],
      winners: winners,
      prize: prize
    }
  end

  def parse_date(date_str)
    return nil if date_str.blank?

    if date_str.match?(/^\d{8}$/)
      Date.strptime(date_str, '%Y%m%d')
    elsif date_str.match?(%r{^\d{2}/\d{2}/\d{2}$})
      Date.strptime(date_str, '%d/%m/%y')
    elsif date_str.match?(%r{^\d{2}/\d{2}/\d{4}$})
      Date.strptime(date_str, '%d/%m/%Y')
    else
      nil
    end
  rescue Date::Error
    nil
  end

  def extract_winners(row)
    winners_key = row.headers.find do |h|
      h&.include?('nombre_de_gagnant_au_rang1') && h&.include?('europe')
    end

    return 0 unless winners_key

    row[winners_key].to_i
  end

  def extract_prize(row)
    prize_key = row.headers.find do |h|
      h&.include?('rapport_du_rang1')
    end

    return 0 unless prize_key

    prize_str = row[prize_key].to_s
    return 0 if prize_str.blank? || prize_str == '0'

    prize_str.gsub(/[^\d,.]/, '').gsub(',', '.').to_f.round
  end
end

