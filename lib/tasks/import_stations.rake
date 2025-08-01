namespace :stations do
  desc 'Import Ontario charging stations from OpenChargeMap'
  task import_ontario: :environment do
    puts 'Starting import of Ontario charging stations...'
    ChargingStationImporter.import_ontario_stations
    puts 'Import completed!'
  end
end