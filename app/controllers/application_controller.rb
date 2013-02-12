class ApplicationController < ActionController::Base
  	protect_from_forgery
	before_filter :getPages

  	include Twitter::Login::Helpers
    
  	def logged_in?
    	!!session[:twitter_user]
  	end
 	helper_method :logged_in?
 	def getPages
		user = User.where(:blog_subdomain=>request.subdomain)
		user.each do |userD|
			@userName = userD[:screen_name]
		end
        
        headers['X-Version'] = PostHub::Application::GIT_SHA   
        
		@page = Page.where(:author=>@userName)
		

	end
	


end