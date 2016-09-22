class CreateAccountIpoWinLots < ActiveRecord::Migration
  def change
    create_table :account_ipo_win_lots do |t|

    	t.string			:apply_code																		#申购代码
    	t.integer			:win_lot_count,						:limit => 4					#中签数量
    	t.string			:win_lot_numbers,					:limit => 256				#中签号
      t.references 	:account_info, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
