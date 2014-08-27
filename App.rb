require './model'
require './api/users'
require './api/devs'

module KarriApps

	class API < Grape::API
		format :json

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