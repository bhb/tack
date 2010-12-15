module Kernel

  def rbx?
    defined?(RUBY_ENGINE) && RUBY_ENGINE=='rbx'
  end

  def debugger
    message =<<-EOS

#{"*"*10} 'debugger' is not defined. Run with -u option to enable. #{"*"*10}
('debugger' called from #{caller.first})
    EOS
    if rbx?
      begin
        Debugger.start
      rescue NameError
        puts message
      end
    else
      if defined?(super)
        super
      else
        puts message
      end
    end
  end

end

