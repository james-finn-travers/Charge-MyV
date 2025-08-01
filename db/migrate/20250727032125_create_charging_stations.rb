class CreateChargingStations < ActiveRecord::Migration[8.0]
  def change
    create_table :charging_stations do |t|
      t.string :name
      t.string :address
      t.decimal :latitude
      t.decimal :longitude
      t.string :connector_types
      t.string :availability
      t.decimal :power_output

      t.timestamps
    end
  end
end
