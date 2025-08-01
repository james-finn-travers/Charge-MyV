class CreateChargingStations < ActiveRecord::Migration[7.1]
  def change
    create_table :charging_stations do |t|
      t.string :name, null: false
      t.string :address, null: false
      t.decimal :latitude, precision: 10, scale: 6, null: false
      t.decimal :longitude, precision: 10, scale: 6, null: false
      t.string :connector_types, null: false
      t.string :availability
      t.decimal :power_output, precision: 6, scale: 2
      t.string :provider
      t.string :hours_of_operation
      t.boolean :is_public, default: true
      t.string :payment_methods
      t.text :description

      t.timestamps
    end

    add_index :charging_stations, [:latitude, :longitude]
    add_index :charging_stations, :connector_types
    add_index :charging_stations, :provider
  end
end