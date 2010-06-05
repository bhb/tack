require 'test/unit'
require 'test/unit/testresult'

Test::Unit.run = true

class TestUnitAdapter

  def tests_for(file)
    require file
    classes = test_classes_for(file)
    classes.inject([]) do |tests, klass|
      tests += test_methods(klass).map {|method_name| [file, method_name]}
    end
  end

  def run(path, description)
    results = { :passed => [],
      :failed => [],
      :pending => []}
    #tests.each do |file, description|
      require(path)
      # Note that this won't work if there are multiple classes in a file
      klass = test_classes_for(path).first 
      test = klass.new(description)
      result = Test::Unit::TestResult.new
      test.run(result) do |started,name|
        # We do nothing here
        # but this method requires a block
      end
    if result.passed?
      results[:passed] << {:description => description}
    else
      results[:failed] << {:description => description}
    end
    results
  end

  private
  
  def test_classes_for(file)
    # taken from from hydra
    #code = ""
    #    File.open(file) {|buffer| code = buffer.read}
    code = File.read(file)
    matches = code.scan(/class\s+([\S]+)/)
    klasses = matches.collect do |c|
      begin
        if c.first.respond_to? :constantize
          c.first.constantize
        else
          eval(c.first)
        end
      rescue NameError
        # means we could not load [c.first], but thats ok, its just not
        # one of the classes we want to test
        nil
      rescue SyntaxError
        # see above
        nil
      end
    end
    return klasses.select{|k| k.respond_to? 'suite'}
  end

  def test_methods(test_class)
    test_class.instance_methods.select do |method_name|
      method_name =~ /^test./ &&
        (test_class.instance_method(method_name).arity == 0 ||
         test_class.instance_method(method_name).arity == -1
         )
    end
  end

  def get_test_classes
    test_classes = []
    ObjectSpace.each_object(Class) do |klass|
      if(Test::Unit::TestCase > klass)
        test_classes << klass
      end
    end
    test_classes
  end

end
