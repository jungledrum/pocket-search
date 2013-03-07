class ItemsController < ApplicationController
	def index
		@user = User.find(session[:uid])
		@items = @user.items

		render :json => {:name => "bo",:title => "this is a title"}
	end

	def main
		
	end
end
