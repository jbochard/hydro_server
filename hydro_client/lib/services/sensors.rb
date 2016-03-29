
require 'services/exceptions'
require 'thread'
require 'serialport'
require 'services/arduino'

 class Sensors

    include Singleton
    include Arduino

    def initialize
        @name = Environment.config["server"]["name"]
        @semaphore = Mutex.new
        @cache = {}
        arduino_debug(Environment.debug)
        arduino_config(Environment.config["serial"])
        sync
   end

    def sensors
        state = nil
        value = nil
        @semaphore.synchronize do 
            state, value = execute("LIST")
        end
        @cache = {}
        lstSensors = []
        if state == "OK"
            value.split("|").each do |l| 
                switch, type          = l.split(";") 
                lstSensors = lstSensors << { :name => @name, :sensor => switch, :type => type, :value => {} }
                @cache[switch.upcase]   = { :state => "OK", :value => "EMPTY" }
            end
        end
        return lstSensors            
    end

    def read(command)
        return { :state => "ERROR", :value => "COMMAND EMPTY" } if command.nil?
        return @cache[command.upcase]
    end


    def switch(relay, state)
        return { :state => "ERROR", :value => "#{relay}-#{state} NOT FOUND" } if relay.nil? || ! state.nil?

        command = "#{relay}_ON"  if state.upcase == 'ON'
        command = "#{relay}_OFF" if state.upcase == 'OFF'

        state = nil
        value = nil
        @semaphore.synchronize do 
            state, value = execute(command)
        end
        @cache[relay.upcase] = { :state => state, :value => value }
        return { :state => state, :value => value }
    end

    def real_read(command)
        return { :state => "ERROR", :value => "COMMAND EMPTY" } if command.nil?

        state = nil
        value = nil
        @semaphore.synchronize do 
            state, value = execute(command)
        end
        puts "read return: #{value}" if Environment.debug

        @cache[command.upcase] = { :state => state, :value => value }
        return { :state => state, :value => value } 
    end      
end