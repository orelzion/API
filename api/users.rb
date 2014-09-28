class Users < Grape::API
	resource :users do

		before do 
			authenticate!
		end

		desc "Get all users"
		params do 
			optional :order_by, type: Symbol, values: [:dev_name, :created_at, :updated_at, :email, :id], default: :id
			optional :sort_by,  type: Symbol, values: [:asc, :desc], default: :asc
			optional :limit, type: Integer, default: 1000
			optional :offset, type: Integer, default: 0
		end
		get do
			limit = params[:limit]
			offset = params[:offset]
			users_count = User.all.length
			path = "#{env['PATH_INFO']}" + "#{env['QUERY_STRING']}"

			if(:sort_by == :asc) then 
				users = User.all(:offset => offset, :limit => limit, :order => params[:order_by].asc)
			else
				users = User.all(:offset => offset, :limit => limit, :order => params[:order_by].desc)
			end
			type = @current_dev.access == :read ? :default : :full
			present :users, users, type: type
			present :pages, pages = users_count.fdiv(limit).ceil

			if(pages > 0 && ((offset + limit) < users_count)) then
				present :next, path + "/limit=#{limit}" + "&offset=#{offset + limit}"
			end
			if(pages > 0 && ((offset - limit) > 0)) then
				present :previous, path + "/limit=#{limit}" + "&offset=#{offset - limit}"
			end
		end

		params do 
			requires :id, type: Integer
		end
		route_param :id do
			get do 
				User.all(:id => params[:id])
			end
		end
		
		namespace :findByEmail do
			desc "Find user by email"
			params do 
				requires :email, type: String, desc: "User's email"
			end
			route_param :email do
				get do 
					User.all(:email => params[:email])
				end
			end
		end


		desc "Create a user (with app data)"
		post do
			if(@current_dev.access != :create && @current_dev.access != :all) then 
				error!("You cannot create new users", 301)
			end
			user = User.from_json params
			user
		end


	end
end