namespace :db do
  desc 'Reset database and import Ontario charging stations'
  task reset_and_import: :environment do
    puts "Resetting database..."
    Rake::Task['db:reset'].invoke
    
    puts "Importing Ontario charging stations..."
    ChargingStationImporter.import_ontario_stations
  end
end