# lib/tasks/import_stations.rake
namespace :stations do
  desc 'Import Ontario charging stations from OpenChargeMap'
  task import_ontario: :environment do
    ChargingStationImporter.import_ontario_stations
  end
end