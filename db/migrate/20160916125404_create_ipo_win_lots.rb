class CreateIpoWinLots < ActiveRecord::Migration
  def change
    create_table :ipo_win_lots do |t|
      t.string 	:apply_code,					:limit => 20				#申购代码
      t.string 	:ballot_numbers,			:limit => 1024			#中签号

      t.timestamps null: false
    end
  end
end
