require 'rubygems'
require 'data_mapper'
require 'dm-types'
require 'bcrypt'

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/main.db")

class User
	include DataMapper::Resource
	include BCrypt
	property :id, Serial, :key => true
	property :email, String, :required => true, :lazy => [:auth]
	property :password, BCryptHash, :required => true, :lazy => [:auth]
	property :created_at, DateTime, :default => DateTime.now
	property :updated_at, DateTime
	property :facebook_token, Text, :lazy => [:fb]
	property :facebook_token_updated_at, DateTime, :lazy => [:fb]
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

class App
	include DataMapper::Resource

	property :id, Serial, :key => true
	property :app_name, String, :unique => true
	property :paid_user, Boolean
	property :billing_source, Enum[:google_play, :amazon, :paypal]
	property :purchased_at, DateTime
	property :access_token, String

	belongs_to :user
end

DataMapper.finalize
DataMapper.auto_upgrade!

