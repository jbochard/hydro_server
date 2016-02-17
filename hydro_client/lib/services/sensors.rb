
require 'services/exceptions'
require 'serialport'

 class Sensors

    def initialize
        @serial = SerialPort.new(Environment.config["serial"]["serial_port"], Environment.config["serial"]["baud_rate"], 8, 1, SerialPort::NONE)
    end

    def measures
        Environment.sensors["read"].map { |measure| measure["name"] }        
    end

    def switches
        Environment.sensors["switch"].map { |switch| switch["name"] }
    end

    def read(command)
        cmdObj = Environment.sensors["read"].select { |cmd| cmd["name"].upcase == command.upcase }.first
        if ! cmdObj.nil?
            @serial.write("#{cmdObj['command'].upcase}\n")
            @serial.flush
            sleep(1)
            
            line = readLine
            res = line.scan(/#{cmdObj['command'].upcase}\s+([^ ]+)\s*([^ ]*)$/).last
            puts "Result: #{res}"
            state = res[0]
            value = res[1]
            return { :state => state, :value => value }
        end
        { :state => "ERROR", :description => "COMMAND #{command} NOT FOUND" }
    end

    def switch(relay, state)
        cmdObj = Environment.sensors["switch"].select { |cmd| cmd["name"].upcase == relay.upcase }.first
        if ! cmdObj.nil?
            puts cmdObj.class
            command = cmdObj["on"].upcase if state.upcase == 'ON'
            command = cmdObj["off"].upcase if state.upcase == 'OFF'

            @serial.write("#{command}\n")
            @serial.flush
            sleep(1)
            
            line = readLine
            return { :value => line }
        end
        { :error => "COMMAND (#{relay}, #{state}) NOT FOUND" }
    end

    private
    def readLine
        c = nil
        count = 20
        result = ""
        while c != 13  do
            c = @serial.getbyte
            if ! c.nil?
                result << c
                sleep(0.1)
            else
                if count > 20
                    sleep(0.5)
                    count = count - 1
                else
                    return "ERROR I/O"
                end 
            end
        end
        result
    end          
end