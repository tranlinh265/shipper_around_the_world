class UsersController < ApplicationController
	before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
	before_action :correct_user,   only: [:edit, :update]
	before_action :admin_user,     only: :destroy

	def index
		@users = User.paginate(page: params[:page], :per_page => 8)
	end

	def new
		@user = User.new
	end

	def show
		@user = User.find(params[:id])
		@requests = @user.requests.paginate(page: params[:page], :per_page => 6)
		@request = current_user.requests.build
		@message = Message.new
	end

	def create
		@user = User.new(user_params)
		if @user.rank == 0
			if @user.save
				log_in @user
				flash[:success] = "Welcome to the SAW!"
				redirect_to @user
			else
				render 'new'
			end
		else
			@shipper = User.find_by(email: @user.email)
			rank = @shipper.rank
			total_vote = @shipper.totalvote
			new_rank = (rank * total_vote + @user.rank)/(total_vote +1)
			@shipper.update_attributes(rank: new_rank)
			@shipper.update_attributes(totalvote: total_vote +1)

			@contract = Contract.find(params[:user][:contract_id])
			@contract.update_attributes(state: 2)
			redirect_to root_url
		end
	end

	def edit
		@user = User.find(params[:id])
	end

	def update
		@user = User.find(params[:id])
		if @user.update_attributes(user_params)
			flash[:success] = "Profile updated"
			redirect_to @user
		else
			render 'edit'
		end
	end

	def destroy
		User.find(params[:id]).destroy
		flash[:success] = "User deleted"
		redirect_to users_url
	end

	private

		def user_params
			params.require(:user).permit(:name, :email, :phonenumber, :password,
	                                     :password_confirmation, :rank)
		end

		# Before filters
		
		# Confirms the correct user.
		def correct_user
			@user = User.find(params[:id])
			redirect_to(root_url) unless current_user?(@user)
		end

		# Confirms an admin user.
		def admin_user
			redirect_to(root_url) unless current_user.admin?
		end
end