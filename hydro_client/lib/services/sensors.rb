
require 'services/exceptions'
require 'thread'
require 'serialport'

 class Sensors

    def initialize
        @name = Environment.config["server"]["name"]
        @semaphore = Mutex.new
        begin
            @serial = SerialPort.new(Environment.config["serial"]["serial_port"], Environment.config["serial"]["baud_rate"], Environment.config["serial"]["data_bits"], Environment.config["serial"]["stop_bits"], SerialPort::NONE)
        rescue Exception => e
            puts e
            puts e.backtrace
        end                
    end

    def sensors
        begin
            puts "write LIST" if Environment.debug
            @serial.write("LIST\n")
            @serial.flush 

            line = readLine
            return { :state => 'ERROR', :value => 'READ ERROR' } if line.nil?

            res = line.scan(/([^ ]+)\s*([^ ]*)$/).last
            state = res[0]
            value = res[1] if res.length > 1
            puts "read return: #{value}" if Environment.debug

            sensors = []
            value.split("|").map do |l| 
                (name, type) = l.split(";") 
                sensors << { :name => @name, :sensor => name, :type => type }
            end
            return sensors
        rescue Exception => e
            puts e
            puts e.backtrace

            puts "Restore connection:"
            begin
                @serial.close
            rescue Exception => e
            end
            @serial = SerialPort.new(Environment.config["serial"]["serial_port"], Environment.config["serial"]["baud_rate"], Environment.config["serial"]["data_bits"], Environment.config["serial"]["stop_bits"], SerialPort::NONE)
        end                
    end

    def read(command)
        if ! command.nil?
            puts "waitting for read(#{command})" if Environment.debug            
            @semaphore.synchronize {
                begin
                    puts "write: #{command.upcase}" if Environment.debug
                    @serial.write("#{command.upcase}\n")
                    @serial.flush 

                    line = readLine
                    return { :state => 'ERROR', :value => 'READ ERROR' } if line.nil?

                    res = line.scan(/([^ ]+)\s*([^ ]*)$/).last
                    state = res[0]
                    value = res[1] if res.length > 1
                    puts "read return: #{value}" if Environment.debug
                    return { :state => state, :value => value }
                rescue Exception => e
                    puts e
                    puts e.backtrace

                    puts "Restore connection:"
                    begin
                        @serial.close
                    rescue Exception => e
                    end
                    @serial = SerialPort.new(Environment.config["serial"]["serial_port"], Environment.config["serial"]["baud_rate"], Environment.config["serial"]["data_bits"], Environment.config["serial"]["stop_bits"], SerialPort::NONE)
                end                
            }
        end
        { :state => "ERROR", :value => "#{command} NOT FOUND" }
    end

    def switch(relay, state)
         if ! relay.nil? && ! state.nil?
            puts "waitting for switch(#{relay}, #{state})" if Environment.debug            
            @semaphore.synchronize {
                begin
                    command = "#{relay}_ON".upcase  if state.upcase == 'ON'
                    command = "#{relay}_OFF".upcase if state.upcase == 'OFF'

                    puts "write: #{command}" if Environment.debug
                    @serial.write("#{command}\n")
                    @serial.flush
                    
                    line = readLine
                    return { :state => 'ERROR', :value => 'READ ERROR' } if line.nil?

                    res = line.scan(/([^ ]+)\s*([^ ]*)$/).last
                    state = res[0]
                    value = res[1] if res.length > 1
                    puts "switch return: #{value}" if Environment.debug
                    return { :state => state, :value => value }
                rescue Exception => e
                    puts e
                    puts e.backtrace

                    puts "Restore connection:"
                    begin
                        @serial.close
                    rescue Exception => e
                    end
                    @serial = SerialPort.new(Environment.config["serial"]["serial_port"], Environment.config["serial"]["baud_rate"], Environment.config["serial"]["data_bits"], Environment.config["serial"]["stop_bits"], SerialPort::NONE)
                end
            }
        end
        { :state => "ERROR", :value => "#{relay}-#{state} NOT FOUND" }
    end

    private
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