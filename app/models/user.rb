class User
  	include MongoMapper::Document
	key :screen_name, String
	key :blog_name, String
	key :blog_subdomain, String

	key :admin, Boolean

	timestamps!

	validates_presence_of :screen_name, :blog_name, :blog_subdomain

	validates_uniqueness_of :screen_name, :blog_subdomain

	validate :finalValidate


	before_save :stripSpaces

	def stripSpaces
		self.blog_subdomain = self.blog_subdomain.gsub(/[\ _]/, "-")
	end
	def finalValidate
		if blog_subdomain.length > 10
			errors.add(:blog_subdomain, "Your chosen subdomain is too long, the maximum is 9 characters")
		end
		case blog_subdomain
			when "www"
			when "api"
			errors.add(:blog_subdomain," - Sorry but that subdomain is reserved!")
		end
	end
end
