class SimplifyChargingStations < ActiveRecord::Migration[8.0]
  def change
    # Drop the existing table if it exists
    drop_table :charging_stations, if_exists: true

    # Create a new simplified table
    create_table :charging_stations do |t|
      t.string :name, null: false
      t.string :address, null: false
      t.decimal :latitude, precision: 10, scale: 6, null: false
      t.decimal :longitude, precision: 10, scale: 6, null: false
      t.string :connector_types
      t.decimal :power_output
      t.boolean :is_operational, default: true
      
      t.timestamps
    end

    # Unique constraint to prevent duplicate stations at same location
    add_index :charging_stations, [:latitude, :longitude], unique: true, name: 'index_charging_stations_on_coordinates'
    
    # Performance indexes for common queries
    add_index :charging_stations, :connector_types
    add_index :charging_stations, :power_output, name: 'index_charging_stations_on_kilowatts'
    add_index :charging_stations, :is_operational
    add_index :charging_stations, :name
    add_index :charging_stations, [:is_operational, :power_output], name: 'index_charging_stations_on_operational_power'
    
    # Geographic index for location-based queries (PostGIS style)
    add_index :charging_stations, [:latitude, :longitude], name: 'index_charging_stations_on_location'
  end
end
