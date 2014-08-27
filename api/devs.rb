require 'grape'

class Devs <Grape::API
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

		namespace :email do
			desc "Get dev by email"
			params do
	    		requires :email, type: String, desc: "Dev's email"
	  		end
				get ':email', requirements: { email: /.*/ } do
					logger.info "i'm here"
				authenticate!
				Dev.all(:email => params[:email])
			end
		end

		namespace :key do
			desc "Get dev by API key"
			params do
	    		requires :key, type: String, desc: "Dev's api key"
	  		end
				get ':key' do
				authenticate!
				logger.info("api key is #{params[:key]}")
				Dev.first(:api_key => params[:key])
			end
		end

		desc 'Create a new dev'
		post do 
			authenticate!
			if(current_dev.access == :read ||
				current_dev.access == :modify) then
				error!('You have no rights to create a new dev', 403)
			end
			@dev = Dev.new
			@dev.email = params[:email]
			@dev.dev_name = params[:dev_name]
			@dev.access = params[:access]
			@dev.save
		end

		desc "Modify dev object using API key"
		params do
			requires :key, type: String, desc:"API Key"
			requires :email, type: String, desc:"Dev's email"
			requires :dev_brand, type: String, desc:"Dev's brand_name"
		end
		put ':key', requirements: { email: /.*/ } do
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