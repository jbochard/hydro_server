
class Implementation

	@settings = {}

	def self.register(&block)
		block.call(self)
	end

	def self.[]=(key, value)
		@settings[key] = value
	end

	def self.[](key)
		@settings[key]
	end

	def self.method_missing(m)
		@settings[m]
	end
end