class Maaser < Grape::API

	resource :maaser do
		
		before do 
			authenticate!
		end

		desc 'return all transaction for user id'
		params do 
			requires :user_id, :type => Integer
			optional :year, :type => String
			optional :month, :type => String
		end
		route_param :user_id do
			get do 
				trans = MaaserTransaction.all(:user_id => params[:user_id])

				transactions = Hash.new

				trans.each do |t|
					year, month = t.date.strftime('%Y,%m').split(',')
					transactions[year] ||= Hash.new
					transactions[year][month] = transactions[year][month].to_a << t 
				end

				if(params[:year] && params[:month])  
					present transactions[params[:year]][params[:month]]
				elsif(params[:year]) 
					present transactions[params[:year]]
				else
					present transactions
				end
			end
		end

		desc 'Return the user balance'
		namespace :balance do
			params do
				requires :id, :type => Integer 
			end
			route_param :id do 
				get do 
					outcome = MaaserTransaction.sum(:sum, :conditions => ['user_id = ? AND type = ?', params[:id], 2])
					income  = MaaserTransaction.sum(:sum, :conditions => ['user_id = ? AND type = ?', params[:id], 1])
					present :user_id, :id
					present :balance, (income && outcome) ? income - outcome : 0
				end
			end
		end

		desc 'Update a transaction'
		params do 
			requires :id, :type => Integer
		end
		route_param :id do 
			put do 
				t = MaaserTransaction.all(:id => params[:id])
				if(!t) then
					error!('Transaction is not found', 404)
				end
				t.update(:sum => params[:sum])
				t.update(:description => params[:description])
				t.update(:type => params[:type])
				t.update(:date => params[:date])
				t.update(:updated_at => DateTime.now)

				present MaaserTransaction.all(:order => [:updated_at.desc])
			end  
		end

		desc 'Create a transaction'
		post do 
			t = MaaserTransaction.new
			t.sum = params[:sum]
			t.description = params[:description]
			t.type = params[:type]
			t.date = params[:date] if params[:date]
			t.user_id = params[:user_id]
			t.save

			present MaaserTransaction.all(:order => [:updated_at.desc])
		end

		desc 'Delete a transaction'
		params do 
			optional :id, :type => Integer
		end
		route_param :id do 
			delete do 
				t = MaaserTransaction.all(:id => params[:id])
				if(!t) then
					error!('Transaction is not found', 404)
				end

				t.destroy

				present MaaserTransaction.all(:order => [:updated_at.desc])
			end
		end

		delete do 
			MaaserTransaction.destroy 

			present MaaserTransaction.all(:order => [:updated_at.desc])
		end
	end

end