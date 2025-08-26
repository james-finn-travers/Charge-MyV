namespace :charging_stations do
  desc "Import all Canadian charging stations from OpenChargeMap (FREE - no API key needed)"
  task import_canada: :environment do
    puts "Starting import of Canadian charging stations from OpenChargeMap..."
    puts "This is FREE and doesn't require an API key!"

    begin
      ChargingStationImporter.import_all_canada
      puts "Import completed successfully!"
    rescue => e
      puts "Import failed: #{e.message}"
      puts e.backtrace.first(5).join("\n")
    end
  end

  desc "Import charging stations for a specific province from OpenChargeMap (FREE)"
  task :import_province, [ :province ] => :environment do |task, args|
    province = args[:province]

    if province.blank?
      puts "ERROR: Please specify a province code"
      puts "Example: rails charging_stations:import_province[ON]"
      exit 1
    end

    puts "Importing stations for province: #{province} from OpenChargeMap..."

    begin
      count = ChargingStationImporter.import_province(province)
      puts "Successfully imported #{count} stations for #{province}"
    rescue => e
      puts "Import failed: #{e.message}"
    end
  end
end
