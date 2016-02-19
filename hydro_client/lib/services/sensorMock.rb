require 'thread'

class SensorMock

    def initialize
        @name = Environment.config["server"]["name"]
        @semaphore = Mutex.new
    end

    def measures
        Environment.sensors["read"].map { |measure| { :name => @name, :sensor => measure["sensor"] } }        
    end

    def switches
        Environment.sensors["switch"].map { |switch| { :name => @name, :switch => switch["switch"] } }
    end

    def read(command)
        @semaphore.synchronize {
        	puts "DEBUG: Read #{command}"
    		return { :state => "OK", :value => "35.00" }
        }
    end

    def switch(relay, state)
        @semaphore.synchronize {
        	puts "DEBUG: Switch #{relay}_#{state}"
            return { :state => "OK", :value => nil }
        }
    end
end