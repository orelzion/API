require 'rubygems'
require 'data_mapper'
require 'dm-types'
require 'bcrypt'
require 'grape'
require 'grape-entity'

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/main.db")


class App
	include DataMapper::Resource
	include Grape::Entity::DSL

	def self.from_json(json) 
		app = App.create
		app.app_name = json.app_name
		app.paid_user = json.paid_user
		app.billing_source = json.billing_source
		app.purchased_at = json.purchased_at
		app.access_token = json.access_token
		app
	end

	entity do 
		expose :app_name
		expose :paid_user
		expose :billing_source
		expose :purchased_at
		expose :access_token, if: {type: :full}
	end

	property :id, Serial, :key => true
	property :app_name, String, :unique => true
	property :paid_user, Boolean
	property :billing_source, Enum[:google_play, :amazon, :paypal]
	property :purchased_at, DateTime
	property :access_token, String

	belongs_to :user
end

class User
	include DataMapper::Resource
	include Grape::Entity::DSL
	include BCrypt

	def self.from_json(json)

		user = User.new
		user.first_name = json.first_name
		user.last_name = json.last_name
		user.email = json.email
		user.password = json.login_data.password
		user.facebook_token = json.login_data.facebook_token
		user.facebook_token_updated_at = json.login_data.facebook_token_updated_at
		json.apps.each do |japp|
			app = App.from_json(japp)
			user.apps << app
		end
		user.save
		user
	end

	entity do 
		expose :first_name
		expose :last_name
		expose :email
		expose :id
		expose :user_key, if: {type: :full}
		expose :apps, using: App::Entity

		expose :login_data, if: {type: :full} do 
			expose :password
			expose :facebook_token
			expose :facebook_token_updated_at
		end

		expose :created_at
		expose :updated_at

		expose :url do |user,opts| 
      		"http://#{opts[:env]['HTTP_HOST']}" + 
        	"/users/#{user.id}"
    	end
	end

	property :id, Serial, :key => true
	property :email, String, :required => true, :lazy => [:auth], unique: true
	property :first_name, String
	property :last_name, String
	property :password, BCryptHash, :required => true, :lazy => [:auth]
	property :created_at, DateTime, :default => DateTime.now
	property :updated_at, DateTime
	property :facebook_token, Text#, :lazy => [:fb]
	property :facebook_token_updated_at, DateTime#, :lazy => [:fb]
	property :user_key, APIKey, :default => APIKey.generate

	has n, :apps
end

class Dev
	include DataMapper::Resource

	property :id, Serial, :key => true
	property :email, String
	property :dev_name, String, :unique => true
	property :api_key, APIKey, :default => APIKey.generate
	property :access, Enum[:read, :modify, :create, :all], :default => :read
	property :created_at, DateTime, :default => DateTime.now
	property :updated_at, DateTime, :default => DateTime.now

	def self.authenticate! (api_key)
		first(:api_key => api_key)
	end
end

class MaaserTransaction
	include DataMapper::Resource
	include Grape::Entity::DSL

	property :id, Serial, :key => true
	property :sum, Float, required: true
	property :description, String
	property :type, Enum[:income, :outcome]
	property :date, DateTime, :default => DateTime.now
	property :updated_at, DateTime, :default => DateTime.now
	property :user_id, Integer

	entity do 
		expose :id 
		expose :user_id
		expose :sum 
		expose :description
		expose :type
		expose :date 
		expose :updated_at

		expose :url do |maasertransaction,opts| 
      		"http://#{opts[:env]['HTTP_HOST']}" + 
        	"/maaser/#{maasertransaction.id}"
    	end		
	end
end


DataMapper.finalize
DataMapper.auto_upgrade!

