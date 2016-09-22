class CreateAccountInfos < ActiveRecord::Migration
  def change
    create_table :account_infos do |t|
      t.string :code
      t.references :broker, index: true, foreign_key: true
      t.references :stakeholder, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
