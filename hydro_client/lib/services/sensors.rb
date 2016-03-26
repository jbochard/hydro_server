
require 'services/exceptions'
require 'thread'
require 'serialport'

 class Sensors

    def initialize
        @name = Environment.config["server"]["name"]
        @cache = {}
        @semaphore = Mutex.new
         end

    def sensors
        connect(Environment.config["serial"]) if ! @connected  
        return [] if ! @connected

        @serial.write("LIST\n")
        @serial.flush 
        line = readLine
        #line = execute("LIST")

        res = line.scan(/([^ ]+)\s*([^ ]*)$/).last
        state = res[0]
        value = res[1] if res.length > 1
 
        @cache = {}
        sensors = []
        value.split("|").map do |l| 
            (switch, type) = l.split(";") 
            sensors              << { :name => @name, :sensor => switch, :type => type, :value => {} }
            cache[switch.upcase]  = { :state => "OK", :value => "EMPTY" }
        end
        return sensors            
    end

    def read(command)
        return { :state => "ERROR", :value => "COMMAND EMPTY" } if command.nil?
        return @cache[command.upcase]
    end


    def switch(relay, state)
        return { :state => "ERROR", :value => "#{relay}-#{state} NOT FOUND" } if relay.nil? || ! state.nil?

        command = "#{relay}_ON"  if state.upcase == 'ON'
        command = "#{relay}_OFF" if state.upcase == 'OFF'

        line = execute(command)
        res = line.scan(/([^ ]+)\s*([^ ]*)$/).last
        state = res[0]
        value = res[1] if res.length > 1
        @cache[relay.upcase] = { :state => state, :value => value }
        return { :state => state, :value => value }
    end

    def real_read(command)
        return { :state => "ERROR", :value => "COMMAND EMPTY" } if command.nil?

        connect(Environment.config["serial"]) if ! @connected

        line = execute(command)
               
        res = line.scan(/([^ ]+)\s*([^ ]*)$/).last
        state = res[0]
        value = res[1] if res.length > 1
        puts "read return: #{value}" if Environment.debug

        @cache[command.upcase] = { :state => state, :value => value }
        return { :state => state, :value => value } 
    end

    private
    def execute(command)
        tries = 3
        begin
            puts "write: #{command.upcase}" if Environment.debug
       # @semaphore.synchronize {
            @serial.write("#{command.upcase}\n")
            @serial.flush 
            sleep(1)
            line = readLine
       # }
        return line
        rescue Exception => e
            puts e
            puts e.backtrace

            puts "Restore connection:"
            disconnect
            connect(Environment.config["serial"])
            tries -= 1
            retry unless tries == 0
        end                
        return "ERROR READ_ERROR"
    end

    def connect(data)
        puts "Connecting..." if Environment.debug
        #@semaphore.synchronize {
        begin
            @serial = SerialPort.new(data["serial_port"], data["baud_rate"], data["data_bits"], data["stop_bits"], SerialPort::NONE)
            @connected = true
            puts "Connected." if Environment.debug
        rescue Exception => e
            puts e
            puts e.backtrace
            @connected = false
        end
        #}                
    end

    def disconnect
        puts "Disconnecting..." if Environment.debug
        #@semaphore.synchronize {
        begin
            @serial.close
            @connected = false
        rescue Exception => e
            @connected = false
        end
        #}
    end

    def readLine
        puts "readLine:" if Environment.debug
        state = :char
        count = 20
        result = ""
        while state != :cr  do
            c = @serial.getbyte
            puts "char: #{c}" if Environment.debug

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
            else
                puts "char: nil - count: #{count}" if Environment.debug
                if count > 0
                    sleep(1)
                    count = count - 1
                else
                    return nil
                end 
            end
        end
        puts "readLine result: #{result}" if Environment.debug
        result
    end          
end