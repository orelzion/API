class Devs < Grape::API
	resource :devs do

		before do 
			authenticate!
			if(current_dev.access != :all) then 
				error!('You have no right to access devs DB', 403) 
			end
		end

		desc "Get all devs", hidden: true
		params do 
			optional :order_by, type: Symbol, values: [:dev_name, :created_at, :updated_at, :email, :id], default: :id
			optional :sort_by,  type: Symbol, values: [:asc, :desc], default: :asc
		end
		get do
			if(params[:sort_by] == :asc) then
				Dev.all(:order => params[:order_by].asc)
			else
				Dev.all(:order => params[:order_by].desc)
			end
		end

		namespace :email do
			desc "Get dev by email"
			params do
	    		requires :email, type: String, desc: "Dev's email"
	  		end
				get ':email', requirements: { email: /.*/ } do
				Dev.all(:email => params[:email])
			end
		end

		namespace :key do
			desc "Get dev by API key"
			params do
	    		requires :key, type: String, desc: "Dev's api key"
	  		end
				get ':key' do
				Dev.first(:api_key => params[:key])
			end
		end

		desc 'Create a new dev'
		post do 
			dev = Dev.new
			dev.email = params[:email]
			dev.dev_name = params[:dev_name]
			dev.access = params[:access]
			dev.save

			Dev.all(:order => [:updated_at.desc])
		end

		desc "Modify dev object using API key"
		params do
			requires :key, type: String, desc:"API Key"
		end
		put ':key', requirements: { email: /.*/ } do
			dev = Dev.first(:api_key => params[:key])
			if(!dev) then
				error!('Dev key is not found', 404)
			end
			dev.update(:email => params[:email])
			dev.update(:dev_name => params[:dev_name])
			dev.update(:access => params[:access])
			dev.update(:updated_at => DateTime.now)
			Dev.all(:order => [:updated_at.desc])
		end

		desc "Deletes an entry"
		params do 
			requires :key, type: String, desc:"API Key"
		end
		delete ':key' do
			if dev = Dev.first(:api_key => params[:key]) then
				dev.destroy
				'success'
			else
				error!('Dev not found', 404)
			end
		end
	end
end
