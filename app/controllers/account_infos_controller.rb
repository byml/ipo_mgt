class AccountInfosController < ApplicationController
	def index
		@account_infos = AccountInfo.all
	end

	def show
		@account_info = AccountInfo.find params['id']
	end
end
