class SessionsController < ApplicationController
	def logout
		twitter_logout
		reset_session
		redirect_to root_path
	end
	
end
