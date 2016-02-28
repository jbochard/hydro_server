
require 'time'

now = Time.new.getlocal.to_s

puts eval('Time.parse(now).hour')