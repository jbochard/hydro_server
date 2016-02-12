
require 'services/exceptions'
require 'serialport'

 class Sensors

    def initialization
        @serial = SerialPort.new Environment.config["serial"]["serial_port"], Environment.config["serial"]["serial_baud"]
    end

    def read(command)
        @serial.write(command)
        result = @serial.read
        puts result
        { :value => result }
   end

    def switch(relay, state)
        @serial.write("#{relay}_#{state}")
        result = @serial.read
        puts result
        { :value => result }
    end          
end