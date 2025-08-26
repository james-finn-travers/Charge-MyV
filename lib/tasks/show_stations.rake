namespace :stations do
  desc 'Show first 6 charging stations'
  task show_first_6: :environment do
    puts "\nFirst 6 Charging Stations:"
    puts "-------------------------"
    
    ChargingStation.limit(6).each do |station|
      puts "\n🔌 Station Details:"
      puts "Name: #{station.name}"
      puts "Address: #{station.address}"
      puts "Location: (#{station.latitude}, #{station.longitude})"
      puts "Connector Types: #{station.connector_types || 'Not specified'}"
      puts "Power Output: #{station.power_output || 'Not specified'} kW"
      puts "Operational: #{station.is_operational ? 'Yes' : 'No'}"
      puts "-------------------------"
    end
  end
end
