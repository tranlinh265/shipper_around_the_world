class RequestsController < ApplicationController
	before_action :correct_user,   only: :destroy
	def new 
		@request = Request.new
		
	end
	def create
		@request = current_user.requests.build(request_params)
		if @request.state == 0
			if @request.save
				flash[:success] = "Request created!"
				redirect_to user_path(current_user)
			else
				flash[:danger] = @request.errors.full_messages.to_sentence
				redirect_to user_path(current_user)
			end
		else 
			$requests = Request.find_by_sql("select id from requests where origin = '#{@request.origin}' and product_type_id = #{@request.product_type_id};")
			redirect_to :action => :find
		end
	end

	def destroy
		if @request.state != 0
			@request.destroy
		    flash[:success] = "Request deleted"
		    redirect_to request.referrer || root_url
		end
	end

	def find
		@request= Request.new
	end


	private

    def request_params
		params.require(:request).permit(:content, :price, :origin, :product_type_id,:state)
    end

    def correct_user
      @request = current_user.requests.find_by(id: params[:id])
      redirect_to root_url if @request.nil?
    end
end