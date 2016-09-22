#新股配号
class CreateAccountIpoMatches < ActiveRecord::Migration
  def change
    create_table :account_ipo_matches do |t|
      t.date        :apply_date                                     #申购日期
      t.string      :apply_code                                     #申购代码
      t.string      :match_code                                     #配号代码
    	t.string			:match_name						 										      #配号名称
    	t.integer			:first_match_number,	:limit => 5								#起始配号
    	t.integer			:match_count,					:limit => 1								#配号数量
      t.references 	:account_info, index: true, foreign_key: true

      #t.timestamps null: true
    end
  end
end
