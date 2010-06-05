class Adapter

  def self.for(path)
    # Using a simple path-based heuristic for now
    case path
    when /test.rb$/ 
      TestUnitAdapter.new
    when /spec.rb$/
      RSpecAdapter.new
    else
      raise "Cannot determine an adapter for path #{path}"
    end
  end

end
