class CreateBrokers < ActiveRecord::Migration
  def change
    create_table :brokers do |t|
      t.string :code
      t.string :name

      t.timestamps null: false
    end
  end
end
