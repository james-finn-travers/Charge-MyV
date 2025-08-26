class AddFieldsToChargingStations < ActiveRecord::Migration[8.0]
  def change
    add_column :charging_stations, :external_id, :string
    add_column :charging_stations, :network, :string
    add_column :charging_stations, :pricing, :string
    add_column :charging_stations, :operating_hours, :string
    add_column :charging_stations, :amenities, :text

    add_index :charging_stations, :external_id, unique: true
  end
end
