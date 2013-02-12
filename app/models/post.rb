class Post
	include MongoMapper::Document
	key :title, String
	key :content, String
	key :author, String
	key :postID, String

	timestamps!

	validates_presence_of :title, :content, :author

	validates_uniqueness_of :postID
	before_save :genID

	def genID
		self.postID = idgen
	end
	
	def idgen(size=5)
	  s = ""
	  size.times { s << (i = Kernel.rand(62); i += ((i < 10) ? 48 : ((i < 36) ? 55 : 61 ))).chr }
	  s
	end
end
