require 'grape'

class Users < Grape::API
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
end