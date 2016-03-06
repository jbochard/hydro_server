require 'thread'

class SensorMock

    def initialize
        @name = Environment.config["server"]["name"]
        @semaphore = Mutex.new
    end

    def sensors
        puts "write mock LIST" if Environment.debug
        line = "OK TEMP_FLUID;SENSOR|SOIL_MOISTURE_1;SENSOR|SOIL_MOISTURE_2;SENSOR|SOIL_MOISTURE_3;SENSOR|PHOTO;SENSOR|HUMIDITY;SENSOR|TEMP_ENV;SENSOR|RELAY_1;SWITCH|RELAY_2;SWITCH|RELAY_3;SWITCH|RELAY_4;SWITCH"

        res = line.scan(/([^ ]+)\s*([^ ]*)$/).last
        state = res[0]
        value = res[1] if res.length > 1
        puts "read mock return: #{value}" if Environment.debug

        sensors = []
        value.split("|").map do |l| 
            (name, type) = l.split(";") 
            sensors << { :name => @name, :sensor => name, :type => type }
        end
        return sensors    
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
            return { :state => "OK", :value => state }
        }
    end
end