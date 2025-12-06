puts "\n\nSEEDING STARTING"

puts "\nCleaning DB"
Draw.destroy_all
puts "DB Cleaned"

puts "\nImporting draws from CSV files..."
use_remote = ENV['FDJ_REMOTE'] == 'true'
imported = CsvDrawImporter.call(use_remote_latest: use_remote)
puts "Total draws imported: #{imported}"

puts "\n\nSEEDING ENDED"
