require './model'
require 'grape'

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

		resource :users do

			desc "Get all users"
			get do
				authenticate!
				User.all
			end

			desc "Get user by email"
			get :email do
				authenticate!
				User.all(:email == params[:email])
			end

		end

		resource :devs do

			desc "Get all devs"
			params do
        		optional :limit, type: Integer, desc: "Limit result"
      		end
			get do
				logger.info("i'm here lol")
				authenticate!
				Dev.all
			end

			desc "Get dev by email"
			params do
        		requires :email, type: String, desc: "Dev's email"
      		end
  			get ':email', requirements: { email: /.*/ } do
				authenticate!
				Dev.all(:email => params[:email])
			end

			#desc "Get dev by API key"
			#get :key do
			#	authenticate!
			#	@dev = Dev.first(:api_key == params[:key])

			#	!error('email not found', 204) unless @devs.length > 0
			#end

			desc "Modify dev object using API key"
			params do
				requires :key, type: String, desc:"API Key"
				requires :email, type: String, desc:"Dev's email"
				requires :dev_brand, type: String, desc:"Dev's brand_name"
			end
			put ':key', requirements: { email: /.*/ } do
				logger.info("i'm in put dev")
				authenticate!
				if(current_dev.access == :read) then 
					error!('You have no right to modify', 403) 
				end
				@dev = Dev.first(:api_key => params[:key])
				@dev.update(:email => params[:email])
				@dev.update(:dev_name => params[:dev_brand])
				@dev
			end

			desc "Deletes an entry"
			params do 
				requires :key, type: String, desc:"API Key"
			end
			delete ':key' do
				authenticate!
				if(current_dev.access != :all) then
					error!('You have no right to delete a dev', 403)
				end
				if @dev = Dev.first(:api_key => params[:key]) then
					@dev.destroy
					'success'
				else
					'Dev not found'
				end
			end
		end
	end
end