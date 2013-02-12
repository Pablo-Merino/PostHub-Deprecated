class Page
  	include MongoMapper::Document

	key :title, String
	key :content, String
	key :author, String
	key :slug, String

	timestamps!

	validates_presence_of :title, :content, :author

	validates_uniqueness_of :slug
	before_save :genSlug

	def genSlug
		self.slug = to_slug(self.title)
	end
	private
	def to_slug(str)
		str = str.strip
		str.gsub! /['`]/,""
		str.gsub! /\s*@\s*/, " at "
		str.gsub! /\s*&\s*/, " and "
		str.gsub! /\s*[^A-Za-z0-9\.\-]\s*/, '_'  
		str.gsub! /_+/,"_"
		str.gsub! /\A[_\.]+|[_\.]+\z/,""
		str.gsub! ".","_"
		str
  	end
end
