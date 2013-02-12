class BlogController < ApplicationController
	require "post"
	require "user"
	require "comment"
	require "page"

	require 'grackle'

	def showBlog
		@subdomain = request.subdomain
		user = User.where(:blog_subdomain=>@subdomain)
		if @subdomain == "api"
			redirect_to "/v1"
		else
			if user.empty?
				render "errors/notfound"
			else
				user.each do | userD |
					@data = userD
				end

				posts = Post.where(:author=>@data[:screen_name]).order(:created_at.desc)
				if !posts.empty?
					@posts = posts
				end
				render 'showBlog'
			end
		end
	end



	def post_get
		if session[:twitter_user]
			render 'post'
		else
			redirect_to root_path
		end
	end
	def post_post
		continue_redirect = false
		if params.has_key?(:postTitle) && params.has_key?(:postContent)
			post = Post.new({
				:title=>params[:postTitle].gsub(%r{</?[^>]+?>}, ''),
				:content=>params[:postContent].gsub(%r{</?[^>]+?>}, ''),
				:author=>session[:twitter_user]['screen_name'].gsub(%r{</?[^>]+?>}, '')
			})
			if post.save
				if params[:tweetBox]
					client = Grackle::Client.new(:auth=>{
						:type=>:oauth,
						:consumer_key=>'comsumer_key', :consumer_secret=>'consumer_secret',
						:token=>session[:twitter_access_token][0], :token_secret=>session[:twitter_access_token][1]
					})
					client.statuses.update! :status=>"New post: #{params[:postTitle]} http://#{session[:subdomain]}.#{request.domain}/#{post[:postID]}"
				end
				continue_redirect = true
			else
				errors = Array.new()
				for i in 0..post.errors.full_messages.count
			  		errors.push(post.errors.full_messages[i])
				end
				session[:error] = errors
			end
		else 
			errors = Array.new()
			unless params.has_key?(:postTitle)
				errors.push("Post Title is Required")
			end
			
			unless params.has_key?(:postContent)
				errors.push("Post Content is Required")
			end	
			session[:error] = error	
		end
		
		if continue_redirect
			user = User.where(:screen_name=>post.author)
			user.each do |d|
				redirect_to "http://#{d[:blog_subdomain]}.#{request.domain}/#{post[:postID]}"
			end
		else
			render "blog/post"
		end
	end
	def getpost

		@post = Post.where(:postID=>params[:pid])
		@post.each do |data|
			@user = User.where(:screen_name=>data['author'])
			@user.each do |user|
				@userSubdomain = user[:blog_subdomain]
				@blogName = user[:blog_name]
				@userName = user[:screen_name]
			end
			@comments = Comment.where(:postID=>params[:pid])

		end

		if request.subdomain != @userSubdomain
			if request.subdomain == "" || request.subdomain == "www"
				redirect_to root_path
			else
				render "errors/notfound"
			end
		end

	end
	def killBlog
		if session[:twitter_user]
		else 
			redirect_to root_path
		end

	end
	def killBlog_post
		if session[:twitter_user]
			user = User.where(:screen_name=>session[:screen_name])
			posts = Post.where(:author=>session[:screen_name])
			user.each do | userD |
				posts.each do |post|
					unless post.nil?
						post.destroy
					end
				end
				if userD.destroy
					reset_session
					twitter_logout
					flash[:success] = "Blog deleted successfully"
					redirect_to "http://#{request.domain}"
				else
					render "index"
				end
			end

		else
			redirect_to root_path
		end
	end

	def destroypost
		@post = Post.where(:postID=>params[:pid])
		@post.each do |data|
			if data.destroy
				flash[:success] = "Post successfully deleted"
				redirect_to root_path
			end

		end

	end
	def comment
		comment = Comment.new({
			:content => params[:commentContent],
			:author => params[:authorName],
			:postID => params[:pid]
		})
		if comment.save
			flash[:success] = "Comment sent!"
			redirect_to "/#{params[:pid]}"
		else
			errors = Array.new()
			for i in 0..comment.errors.full_messages.count
		  		errors.push(comment.errors.full_messages[i])
			end
			session[:error] = errors
			flash[:error] = "Error sending comment! Please try again!"
			redirect_to "/#{params[:pid]}"
		end
	end

	def newPage
		if session[:twitter_user]
			render 'page'
		else
			redirect_to root_path
		end
	end

	def newPage_post
		page = Page.new({
			:title=>params[:pageTitle].gsub(%r{</?[^>]+?>}, ''),
			:content=>params[:pageContent].gsub(%r{</?[^>]+?>}, ''),
			:author=>session[:twitter_user]['screen_name'].gsub(%r{</?[^>]+?>}, '')
		})
		if page.save
			if params[:tweetBox]
				client = Grackle::Client.new(:auth=>{
					:type=>:oauth,
					:consumer_key=>'dRMrhSqNbnksci374CQjwA', :consumer_secret=>'qUv61aEXxpTRqLQ0Su1bsP2N5P6NZBSrAk3EJe1F6ew',
					:token=>session[:twitter_access_token][0], :token_secret=>session[:twitter_access_token][1]
				})
				client.statuses.update! :status=>"New page: #{params[:pageTitle]} http://#{session[:subdomain]}.#{request.domain}/p/#{page[:slug]}"
			end
			flash[:success] = "Page saved!"
			redirect_to "http://#{session[:subdomain]}.#{request.domain}/p/#{page.slug}"
		else
			errors = Array.new()
			for i in 0..page.errors.full_messages.count
		  		errors.push(page.errors.full_messages[i])
			end
			session[:error] = errors
			render "blog/page"
		end

	end

	def showPage

		@page = Page.where(:slug=>params[:pageID])
		@page.each do |data|
			@user = User.where(:screen_name=>data['author'])
			@user.each do |user|
				@userSubdomain = user[:blog_subdomain]
				@blogName = user[:blog_name]
				@userName = user[:screen_name]
			end
			@pageData = data
		end

		if request.subdomain != @userSubdomain
			if request.subdomain == "" || request.subdomain == "www"
				redirect_to root_path
			else
				render "errors/notfound"
			end
		end

		
	end
	def destroyPage
		@page = Page.where(:slug=>params[:pageID])
		@page.each do |data|
			if data.destroy
				flash[:success] = "Page successfully deleted"
				redirect_to root_path
			end

		end


	end

end
