class CreateIpoIssues < ActiveRecord::Migration
  def change
    create_table :ipo_issues do |t|
    	t.string 	:stock_code					#股票代码
      t.string 	:stock_name					#股票简称
      t.string 	:apply_code					#申购代码
      t.string  :match_code         #配号代码
      t.date 	 	:online_apply_date	#申购日期
      t.date 		:lot_declare_date		#中签公告日
      t.date 		:pay_date						#中签缴款日
      t.decimal	:issue_price,				:null => true, :precision => 8, :scale => 2	#发行价
      t.date 		:list_date					#上市日期
      t.decimal :online_lot_rate,		:null => true, :precision => 8, :scale => 3	#中签率
      t.string	:lot_result,				:limit => 1024		#中签号

      t.timestamps null: false
    end
  end
end
