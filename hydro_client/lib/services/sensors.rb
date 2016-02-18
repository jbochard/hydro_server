
require 'services/exceptions'
require 'thread'
require 'serialport'

 class Sensors

    def initialize
        @semaphore = Mutex.new
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
            @semaphore.synchronize {
                @serial.write("#{cmdObj['command'].upcase}\n")
                @serial.flush            
                line = readLine
                return { :state => 'ERROR', :value => 'I/O ERROR' } if line.nil?

                res = line.scan(/#{cmdObj['command'].upcase}\s+([^ ]+)\s*([^ ]*)$/).last
                state = res[0]
                value = res[1] if res.length > 1
                return { :state => state, :value => value }
            }
        end
        { :state => "ERROR", :value => "#{command} NOT FOUND" }
    end

    def switch(relay, state)
        cmdObj = Environment.sensors["switch"].select { |cmd| cmd["name"].upcase == relay.upcase }.first
        if ! cmdObj.nil?
            @semaphore.synchronize {
                command = cmdObj["on"].upcase if state.upcase == 'ON'
                command = cmdObj["off"].upcase if state.upcase == 'OFF'

                @serial.write("#{command}\n")
                @serial.flush
                
                line = readLine
                return { :state => 'ERROR', :value => 'I/O ERROR' } if line.nil?

                res = line.scan(/#{cmdObj['command'].upcase}\s+([^ ]+)\s*([^ ]*)$/).last
                state = res[0]
                value = res[1] if res.length > 1
                return { :state => state, :value => value }
            }
        end
        { :state => "ERROR", :value => "#{relay}-#{state} NOT FOUND" }
    end

    private
    def readLine
        state = :char
        count = 20
        result = ""
        while state != :cr  do
            c = @serial.getbyte
             if ! c.nil?
                if c == 13
                    state = :lf
                    next
                end
                if state == :lf  && c == 10
                    state = :cr
                    next
                else
                    state = :char
                end
                result << c
                sleep(0.1)
            else
                if count > 20
                    sleep(0.5)
                    count = count - 1
                else
                    return nil
                end 
            end
        end
        result
    end          
end