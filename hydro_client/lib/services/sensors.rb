
require 'services/exceptions'
require 'serialport'

 class Sensors

    def initialize
        @serial = SerialPort.new(Environment.config["serial"]["serial_port"], Environment.config["serial"]["baud_rate"], 8, 1, SerialPort::NONE)
    end

    def read(command)
        cmdObj = Environment.config["read"].select { |cmd| cmd["name"].upcase == command.upcase }.first
        if ! cmdObj.nil?
            @serial.write("#{cmdObj['command'].upcase}\n")
            @serial.flush
            sleep(1)
            
            line = readLine
            value = line.scan(/#{cmdObj['command'].upcase}\s*([^ ]+)\s*OK\s*/).last.first
             return { :value => value }
        end
        { :error => "COMMAND #{command} NOT FOUND" }
    end

    def switch(relay, state)
        state = "on" if state.upcase == 'ON'
        state = "off" if state.upcase == 'OFF'
        
        cmdObj = Environment.config["switch"].select { |cmd| cmd["name"].upcase == relay.upcase }.first
        if ! cmdObj.nil?
            @serial.write("#{cmdObj[state].upcase}\n")
            @serial.flush
            sleep(1)
            
            line = readLine
            value = line.scan(/#{cmdObj[state].upcase}\s*([^ ]+)\s*OK\s*/).last.first
            return { :value => cmdObj[state].upcase }
        end
        { :error => "COMMAND (#{relay}, #{state}) NOT FOUND" }
    end

    private
    def readLine
        c = nil
        result = ""
        while c != 13  do
            c = @serial.getbyte
            result << c
            sleep(0.1)
        end
        result
    end          
end