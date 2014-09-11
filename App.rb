require './model'
require './api/users'
require './api/devs'

module KarriApps

	if(Dev.all.length == 0) then
		@dev = Dev.new
		@dev.dev_name = 'Karri Apps'
		@dev.email = 'orelzion@gmail.com'
		@dev.access = :all
		@dev.api_key = '95569127a9facf605688e686b86f4a05002c0dfc'
		@dev.save
	end

	class API < Grape::API
		format :json
		default_error_formatter :txt

		helpers do
			def logger
      			API.logger
    		end
			def current_dev
				logger.info("api key #{headers['Apikey']}")
				@current_dev ||= Dev.authenticate!(headers['Apikey'])
			end
			def authenticate!
				error!('401 Unauthorized', 401) unless current_dev
			end
		end

		mount Users
		mount Devs

	end
end