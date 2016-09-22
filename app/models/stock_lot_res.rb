class StockLotRes
  URL = 'http://stock.jrj.com.cn/action/Stocktrade/queryStockLotRes.jspa'

  #获取中签号
  def self.query(stock_code)
    ballot_numbers_hash = {}
    params = {stockCode: stock_code, _:  Time.now.to_s}
    response = RestClient.get(URL, {:params => params})
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
        ballot_numbers = []
        ballot_number_str.split(',').each do |ballot_number|
          ballot_numbers << ballot_number.strip
        end
        ballot_numbers_hash[digit] = ballot_numbers
      end
    end
    ballot_numbers_hash
  end

  #查询是否中签
  #stock_matching_list 新股配号列表 格式：股票代码 起始配号 配号数量 [{stock_code: '730908', from_number: 323332233, quantity: 15}, {stock_code: '002807', from_number: 323356840, quantity: 20}]
  def self.check(stock_matching_list = [{stock_code: '730908', from_number: 323332233, quantity: 15}, {stock_code: '002807', from_number: 323356840, quantity: 20}])
    check_results = []
    response = {'check_results' => check_results}
    stock_matching_list.each do |stock_matching|
      stock_code = stock_matching[:stock_code]
      ballot_numbers = query(stock_code)
      if ballot_numbers.blank?
        check_result = {stock_code: stock_code, result: -1}
      else
        check_result = {stock_code: stock_code, result: 2}
        from_number = stock_matching[:from_number]
        to_number = from_number + stock_matching[:quantity] - 1
        (from_number..to_number).each do |current_number|
          current_number_str = current_number.to_s
          ballot_numbers.each do |ballot_number|
            if current_number_str.end_with?(ballot_number)
              check_result[:result] = 1
              check_result[:number] = current_number
              break
            end
          end
        end
      end
      check_results << check_result
    end
    response
  end

end