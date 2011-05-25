require 'base64'

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
      #begin; STDOUT.reopen "/dev/null"; rescue ::Exception; end
      #begin; STDIN.reopen "/dev/null"; rescue ::Exception; end
      #begin; STDERR.reopen "/dev/null"; rescue ::Exception; end

      @reader.close
      result = block.call

      @writer.write(Base64.encode64(Marshal.dump([:ok, result])))
    rescue Object => error
      @writer.write(Base64.encode64(Marshal.dump([:error, error])))
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
      status, result = Marshal.load(Base64.decode64(data))
      case status
      when :ok
        return result
      when :error
        error = result
        raise error
      else
        raise "Unknown status #{status}"
      end
    end

  end

end
