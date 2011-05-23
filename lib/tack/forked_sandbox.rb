module Tack

  class ForkedSandbox
    
    def run(&block)
      @reader, @writer = IO.pipe
      value = nil
      if @child = fork
        value = proceed_as_parent
      else
        proceed_as_child(&block)
      end
      value
    end

    private

    def proceed_as_child(&block)
      begin; STDOUT.reopen "/dev/null"; rescue ::Exception; end
      begin; STDIN.reopen "/dev/null"; rescue ::Exception; end
      begin; STDERR.reopen "/dev/null"; rescue ::Exception; end

      @reader.close
      result = block.call
      Marshal.dump([:ok, result], @writer)
    rescue Object => error
      Marshal.dump([
                    :error,
                    #[error.class, error.message, error.backtrace]
                    error
                   ],
                   @writer)
    ensure
      @writer.close
      exit! error ? 1 : 0
    end

    def proceed_as_parent
      @writer.close
      read_data_from_child
    ensure
      @reader.close
    end

    def read_data_from_child
      data = ""
      while !(chunk=@reader.read).empty?
        data << chunk
      end
      status, result = Marshal.load(data)
      case status
      when :ok
        return result
      when :error
        #error_class, error_message, backtrace = result
        #error = error_class.new(error_message)
        #error.set_backtrace(backtrace)
        error = result
        raise error
      else
        raise "Unknown status #{status}"
      end
    end

  end

end
