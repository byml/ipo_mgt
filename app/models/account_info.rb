#账户信息
class AccountInfo < ActiveRecord::Base
	belongs_to :broker
	belongs_to :stakeholder
end
