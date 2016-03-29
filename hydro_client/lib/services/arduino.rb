require 'io/wait'

module Arduino

    @debug = false
    @config = {}

    def arduino_debug(dbg)
        @debug = dbg
    end

    def arduino_config(conf)
        @config = conf
    end

    def sync
        serial = nil
        tries = 3
        begin
            serial = SerialPort.new(@config["serial_port"], @config["baud_rate"], @config["@config_bits"], @config["stop_bits"], SerialPort::NONE)
            serial.read_timeout = 2

            state = "ERROR"
            puts "write: SYNC" if @debug
            serial.write("SYNC\n")
            while state != "OK"
                while serial.wait(5).nil?
                    puts "write: SYNC" if @debug
                    serial.write("SYNC\n")
                    sleep(1)
                end
                line = readLine(serial)

                res = line.scan(/([^ ]+)\s*([^ ]*)$/).last
                state = res[0]
                value = res[1] if res.length > 1
            end
            serial.close
        rescue Exception => e
            puts e
            puts e.backtrace

            if ! serial.nil?
                serial.close
                puts "Restore connection:"
                tries -= 1
                sleep(3)
                retry unless tries == 0
            end
        end                        
    end

	def execute(command)
        serial = nil
        tries = 3
        begin
            serial = SerialPort.new(@config["serial_port"], @config["baud_rate"], @config["@config_bits"], @config["stop_bits"], SerialPort::NONE)
            serial.read_timeout = 2

            state = nil
            puts "write: #{command.upcase}" if @debug
            serial.write("#{command.upcase}\n")
         
            while state != "OK" && state != "ERROR"
                while serial.wait(5).nil?
                    serial.write("#{command.upcase}\n")
                    sleep(1)
                end
                line = readLine(serial)
                res = line.scan(/([^ ]+)\s*([^ ]*)$/).last
                state = res[0]
                value = res[1] if res.length > 1
            end

        	return [state, value]
        rescue Exception => e
            puts e
            puts e.backtrace

            if ! serial.nil?
                serial.close
                puts "Restore connection:"
                tries -= 1
                sleep(3)
                retry unless tries == 0
            end
        end                
        ["ERROR", "READ_ERROR"]
    end

    private
    def readLine(serial)
        puts "readLine:" if @debug
        state = :char  
        count = 20 
        result = "" 
 
        while state != :cr  do 
            c = serial.getbyte 
            puts "\tchar: #{c}" if @debug 

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
                puts "\tchar: nil (#{count})" if @debug
                if count > 0 
                    sleep(1) 
                    count = count - 1
                else 
                    return "ERROR" 
                end  
            end 
            sleep(0.1)
        end 

        puts "#{result}" if @debug 
        result 
    end  
end