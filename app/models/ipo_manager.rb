require "execjs"
require "open-uri"
require 'rest-client'

=begin

rescue Exception => e

end
导出各个账户新股配号

录入上海新股配号代码


1. 查询并更新新股发行

2. 查询并记录新股中签

3. 导入账户新股配号

导入byml_招商证券配号记录

4. 更新上海新股发行配号代码

5. 更新账户上海新股申购代码

6. 查询并记录账户新股中签
=end

class IpoManager
	URL_IPO_ISSUE = 'http://stock.jrj.com.cn/ipo/ipo2015/newStockList.js'
  URL_IPO_WIN_LOT = 'http://stock.jrj.com.cn/action/Stocktrade/queryStockLotRes.jspa'

  PATH_ACCOUNT_IPO_MATCHS_GJ = './data/ipo_match/gj/'
  PATH_ACCOUNT_IPO_MATCHS_PA = './data/ipo_match/pa/'
  PATH_ACCOUNT_IPO_MATCHS_DG = './data/ipo_match/dg/'

  def self.run
  	#1. 查询并更新新股发行
  	refresh_ipo_issues

		#2. 查询并记录新股中签
  	refresh_ipo_win_lots

		#3. 导入账户新股配号
  	import_account_ipo_matchs

  	#4. 更新上海新股发行配号代码

  	IpoIssue.connection.execute(
<<SQL
	UPDATE ipo_issues, account_ipo_matches
	SET ipo_issues.match_code = account_ipo_matches.match_code
	WHERE ipo_issues.match_code is NULL
	AND ipo_issues.online_apply_date = account_ipo_matches.apply_date
	AND account_ipo_matches.match_code LIKE '7%'
SQL
  	)

  	#5. 更新账户上海新股申购代码
  	AccountIpoMatch.connection.execute(
<<SQL
	UPDATE account_ipo_matches, ipo_issues
	SET account_ipo_matches.apply_code = ipo_issues.apply_code
	WHERE account_ipo_matches.apply_code is NULL
	AND account_ipo_matches.match_code = ipo_issues.match_code
SQL
  	)

		#6. 查询并记录账户新股中签
		record_account_ipo_win_lots
  end

	#查询并更新新股发行
  def self.refresh_ipo_issues
		source = open(URL_IPO_ISSUE).read
		source = source.encode(Encoding.find("UTF-8"),Encoding.find("GBK"))

		context = ExecJS.compile(source)
		nsiList = context.eval('nsiList')
		column = nsiList['column']
		datas = nsiList['datas']

		datas.each do |data|
			params = {
				stock_code: 				data[column['stockCode']],
				stock_name: 				data[column['stocksName']],
				apply_code:  				data[column['buy_code1']],
				online_apply_date: 	data[column['onl_apl_date']],
				lot_declare_date: 	data[column['lot_dcl_dt']],
				pay_date: 					data[column['pay_date']],
				list_date: 					data[column['list_date']],
				issue_price: 				data[column['iss_prc']],
				online_lot_rate: 		data[column['onl_lot_rate']],
				lot_result: 				data[column['lot_result']],
			}
			params[:match_code] = params[:stock_code] if params[:apply_code] == params[:stock_code]
			ipo_issue = IpoIssue.find_by(stock_code: params[:stock_code])
			if ipo_issue
				ipo_issue.update_attributes!(params)
			else
				IpoIssue.create!(params)
			end
		end
  end

  #查询并记录新股中签
  def self.refresh_ipo_win_lots
    ipo_issues = IpoIssue.all
    #ipo_issues = ipo_issues.where('ipo_issues.online_apply_date BETWEEN ? And ?', Date.today - 27, Date.today)
    ipo_issues = ipo_issues.where('NOT EXISTS (SELECT 1 FROM ipo_win_lots WHERE ipo_issues.apply_code = ipo_win_lots.apply_code)')
    apply_codes = ipo_issues.pluck(:apply_code)
    apply_codes.each do |apply_code|
      ballot_numbers = []
      params = {stockCode: apply_code, _:  Time.now.to_s}
      response = RestClient.get(URL_IPO_WIN_LOT, {:params => params})
      result = JSON.parse(response.body[12, response.body.size])
      if result.present?
        lot_result = result['lot_result']
        lot_map = result['lot_map']
        lot_map.each do |digit, first_ballot_number|
          from_pos = lot_result.index(first_ballot_number)
          to_pos = lot_result.index("\r\n", from_pos)
          if to_pos.nil?
            ballot_number_str = lot_result[from_pos , lot_result.size]
          else
            ballot_number_str = lot_result[from_pos , to_pos - from_pos]
          end
          ballot_number_str.split(',').each do |ballot_number|
            ballot_numbers << ballot_number.strip
          end
        end
        ballot_numbers.sort!{|a,b| a.size <=> b.size}
      end
      IpoWinLot.create!({apply_code: apply_code, ballot_numbers: ballot_numbers.to_s}) if ballot_numbers.present?
    end
  end

  def self.import_account_ipo_matchs
  	import_account_ipo_matchs_of_gj('byml', 2)
  	import_account_ipo_matchs_of_gj('cexo', 4)
  	import_account_ipo_matchs_of_pa('byml', 3)
  	import_account_ipo_matchs_of_pa('maggie', 5)
  	import_account_ipo_matchs_of_dg('mum', 6)
  end

  #导入东莞证券配号记录
  def self.import_account_ipo_matchs_of_gj(child_dir, account_info_id)
  	#删除改账户原有配号记录
  	delete_account_ipo_matchs(account_info_id)

  	account_ipo_matchs = []
  	dir_path = PATH_ACCOUNT_IPO_MATCHS_GJ + child_dir
  	if File.directory? dir_path
  		Dir["#{dir_path}/*.txt"].each do |file_name|
		    File.open(file_name, "r:gb2312") do |file|
		    	lines = file.readlines
		    	lines[3, lines.size - 1].each do |line|
		    		line_datas = line.split(' ')
		    		account_ipo_match = {
		    			account_info_id: 		account_info_id,
		    			apply_date: 				line_datas[0],
		    			match_code: 				line_datas[1],
		    			match_name: 				line_datas[2],
		    			first_match_number: line_datas[3].split(':')[1],
		    			match_count: 				line_datas[4]
		    		}
		    		account_ipo_matchs << account_ipo_match
		    	end
				end
  		end
  	end

  	account_ipo_matchs.each do |account_ipo_match|
  		AccountIpoMatch.create!(account_ipo_match)
  	end
  end

  #导入平安证券配号记录
  def self.import_account_ipo_matchs_of_pa(child_dir, account_info_id)
		#删除改账户原有配号记录
  	delete_account_ipo_matchs(account_info_id)

  	account_ipo_matchs = []
  	dir_path = PATH_ACCOUNT_IPO_MATCHS_PA + child_dir
  	if File.directory? dir_path
  		Dir["#{dir_path}/*.txt"].each do |file_name|
  			puts file_name
		    File.open(file_name, "r:gb2312") do |file|
		    	lines = file.readlines
		    	lines[3, lines.size - 1].each do |line|
		    		line_datas = line.split(' ')
		    		#申购代码为空
		    		line_datas.insert(2, nil) if line_datas.size < 10
		    		account_ipo_match = {
		    			account_info_id: 		account_info_id,
		    			apply_date: 				line_datas[0],
		    			apply_code: 				line_datas[1],
		    			match_name: 				line_datas[2],
		    			first_match_number: line_datas[4],
		    			match_count: 				line_datas[5]
		    		}
		    		account_ipo_matchs << account_ipo_match
		    	end
				end
  		end
  	end

  	account_ipo_matchs.each do |account_ipo_match|
  		AccountIpoMatch.create!(account_ipo_match)
  	end
  end

  #导入东莞证券配号记录
  def self.import_account_ipo_matchs_of_dg(child_dir, account_info_id)
		#删除改账户原有配号记录
  	delete_account_ipo_matchs(account_info_id)

  	account_ipo_matchs = []
  	dir_path = PATH_ACCOUNT_IPO_MATCHS_DG + child_dir
  	if File.directory? dir_path
  		Dir["#{dir_path}/*.txt"].each do |file_name|
  			puts file_name
		    File.open(file_name, "r:gb2312") do |file|
		    	lines = file.readlines
		    	lines[3, lines.size - 1].each do |line|
		    		line_datas = line.split(' ')
		    		account_ipo_match = {
		    			account_info_id: 		account_info_id,
		    			match_code: 				line_datas[0],
		    			match_name: 				line_datas[1],
		    			first_match_number: line_datas[2],
		    			match_count: 				line_datas[3]
		    		}
		    		account_ipo_matchs << account_ipo_match
		    	end
				end
  		end
  	end

  	account_ipo_matchs.each do |account_ipo_match|
  		AccountIpoMatch.create!(account_ipo_match)
  	end
  end

  #删除账户配号记录
  def self.delete_account_ipo_matchs(account_info_id)
  	AccountIpoMatch.delete_all("account_info_id = #{ account_info_id }")
  end

  #查询并记录账户新股中签
  def self.record_account_ipo_win_lots
    account_ipo_matchs = AccountIpoMatch.all
    account_ipo_matchs = account_ipo_matchs.where('NOT EXISTS (SELECT 1 FROM account_ipo_win_lots WHERE account_ipo_matches.account_info_id = account_ipo_win_lots.account_info_id AND account_ipo_matches.apply_code = account_ipo_win_lots.apply_code)')
    account_ipo_matchs.each do |account_ipo_match|
      apply_code = account_ipo_match.apply_code
      ipo_win_lot = IpoWinLot.find_by({apply_code: apply_code})
      if ipo_win_lot.present?
        ballot_numbers = JSON.parse(ipo_win_lot.ballot_numbers)
        if ballot_numbers.present?
          win_lot_count = 0
          win_lot_numbers = []
          from_number = account_ipo_match.first_match_number
          to_number = from_number + account_ipo_match.match_count - 1

          (from_number..to_number).each do |current_number|
            current_number_str = current_number.to_s
            ballot_numbers.each do |ballot_number|
              if current_number_str.end_with?(ballot_number)
                win_lot_count += 1
                win_lot_numbers << current_number_str
                break
              end
            end
          end
          win_lot_numbers = win_lot_numbers.join(',')

          create_account_ipo_win_lot_params = {
            apply_code:       apply_code,
            win_lot_count:    win_lot_count,
            win_lot_numbers:  win_lot_numbers,
            account_info_id:  account_ipo_match.account_info_id
          }
          AccountIpoWinLot.create!(create_account_ipo_win_lot_params)
        end
      end
    end
  end
end