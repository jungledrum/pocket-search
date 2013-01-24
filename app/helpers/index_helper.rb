# encoding=utf-8
module IndexHelper
	def has_follow(user, follow)
		if user.id == follow.id
			return false
		end
		user.follows.each do |x|
			if x.id == follow.id
				return true
			end
		end
		return false
	end
end
