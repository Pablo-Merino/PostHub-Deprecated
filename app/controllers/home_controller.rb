class HomeController < ApplicationController
	require 'user'
	require 'page'

	require 'rdiscount'
	def index
		if session[:twitter_user]
			user = User.where(:screen_name=>session[:twitter_user]['screen_name'])
			if !user.empty?
				session[:is_reg] = 1
				user.each do | userD |
					session[:subdomain] = userD[:blog_subdomain]
					session[:blogname] = userD[:blog_name]
					session[:screen_name] = session[:twitter_user]['screen_name']
					@userName = userD[:screen_name]
					@blogName = userD[:blog_name]
					@blogsubdomain = "#{userD[:blog_subdomain]}.#{request.domain}"
				end
			
			else
				session[:is_reg] = 0
				render 'new'
			end
			
		else
			render 'index'
		end

	end

	def new_get

		if session[:is_reg] == 1
			redirect_to root_path
		else
			render 'new'
		end
		
	end
	def new_post
		if !session[:twitter_user]
			flash[:error] = "Login with Twitter first!"
			redirect_to "/new"
		else
			user = User.new({
				:screen_name => session[:twitter_user]['screen_name'].gsub(%r{</?[^>]+?>}, ''),
				:blog_name => params[:blog_name].gsub(%r{</?[^>]+?>}, ''),
				:blog_subdomain => params[:blog_url].downcase.gsub(%r{</?[^>]+?>}, '').gsub(/[^0-9a-z]/i, '')
			})
			if user.save
				flash[:info] = "Registered!"
				session[:is_reg] = 1
				redirect_to "http://#{user[:blog_subdomain]}.#{request.domain}"
			else
				errors = Array.new()
				for i in 0..user.errors.full_messages.count
			  		errors.push(user.errors.full_messages[i])
				end
				session[:error] = errors
				redirect_to "/new"
		end
		end
	end

	def redirect
		if session[:twitter_user]

			user = User.where(:screen_name=>session[:twitter_user]['screen_name'])
			if !user.empty?
				user.each do | userD |

					redirect_to "http://#{request.domain}/"
				end
			else 
				session[:is_reg] = 0
				redirect_to "/new"
			end
		else

			redirect_to root_path
		end

	end
	def help
	end
	def about
	end
	def dashboard
		if !session[:twitter_user]
			redirect_to root_path
		else
			user = User.where(:screen_name=>session[:screen_name])
			user.each do |userData|
				@username = userData[:screen_name]
				@blogname = userData[:blog_name]
				@blogsubdomain = "#{userData[:blog_subdomain]}.#{request.domain}"
			end
			posts = Post.where(:author=>@username)
			posts.each do |post|
				@postNumber = posts.count
			end
			pages = Page.where(:author=>@username)
			pages.each do |page|
				@pageNumber = pages.count
			end
		end
	end
	def directory

		@users = User.all(:order => :screen_name.asc)

	end
end
