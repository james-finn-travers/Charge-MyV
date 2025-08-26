namespace :stats do
  desc 'Show charging station statistics'
  task stations: :environment do
    total = ChargingStation.count
    operational = ChargingStation.where(is_operational: true).count
    with_power = ChargingStation.where.not(power_output: nil).count
    
    puts "\nCharging Station Statistics:"
    puts "----------------------------"
    puts "Total stations: #{total}"
    puts "Operational stations: #{operational}"
    puts "Stations with power info: #{with_power}"
    
    if total > 0
      puts "\nSample station:"
      sample = ChargingStation.first
      puts "Name: #{sample.name}"
      puts "Address: #{sample.address}"
      puts "Location: (#{sample.latitude}, #{sample.longitude})"
      puts "Connector Types: #{sample.connector_types || 'Not specified'}"
      puts "Power Output: #{sample.power_output || 'Not specified'} kW"
      puts "Operational: #{sample.is_operational ? 'Yes' : 'No'}"
    end
  end
end
