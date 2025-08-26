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

    add_index :charging_stations, [:latitude, :longitude], unique: true
    add_index :charging_stations, :connector_types
  end
end
