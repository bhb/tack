module Tack

  SANDBOX_CODE = "module Sandbox

    def self.prefix
      self.to_s+\"::\"
    end

  end"
  eval SANDBOX_CODE

  module SandboxLoader

    def self.load(path)
      self.clear
      content = File.read(path)
      Sandbox.class_eval(content, path)
    end
    
    def self.clear
      Tack.send(:remove_const, :Sandbox)
      Tack.class_eval(SANDBOX_CODE)
    end
    
  end

end
