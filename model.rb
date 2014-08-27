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
	property :update_at, DateTime
	property :facebook_token, Text, :lazy => [:fb]
	property :facebook_token_updated_at, DateTime, :lazy => [:fb]
	property :apps, Json
	property :user_key, APIKey, :default => APIKey.generate
end

class Dev
	include DataMapper::Resource
	property :id, Serial, :key => true
	property :email, String
	property :dev_name, String, :unique => true
	property :api_key, APIKey, :default => APIKey.generate
	property :access, Enum[:read, :modify, :create, :all], :default => :read

	def self.authenticate! (api_key)
		first(:api_key => api_key)
	end
end

class App
	attr_accessor :app_name
	attr_accessor :paid_user
	attr_accessor :billing_source
	attr_accessor :purchased_at
	attr_accessor :access_token
end

DataMapper.finalize
DataMapper.auto_upgrade!

