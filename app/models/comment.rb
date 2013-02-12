class Comment
  	include MongoMapper::Document

	key :content, String
	key :author, String
	key :commentID, String
	key :postID, String

	timestamps!

	validates_presence_of :content, :author, :postID

	validates_uniqueness_of :commentID

	validate :finalValidate

	before_save :genID


	def genID
		self.commentID = idgen
	end
	
	def idgen(size=5)
	  s = ""
	  size.times { s << (i = Kernel.rand(62); i += ((i < 10) ? 48 : ((i < 36) ? 55 : 61 ))).chr }
	  s
	end
	def finalValidate
		if author.length > 15
			errors.add(:author, "Your username is way too big, the maximum length is 15 characters")
		end
	end
end
