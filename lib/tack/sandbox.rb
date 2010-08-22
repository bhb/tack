module Tack

  module Sandbox
  end

  module SandboxLoader

    def self.load(path)
      self.clear
      content = File.read(path)
      Sandbox.class_eval(content, path)
    end
    
    def self.clear
      Tack.send(:remove_const, :Sandbox)
      Tack.class_eval("module Sandbox; end;")
    end

  end

end
