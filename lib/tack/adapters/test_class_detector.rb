module Tack

  module Adapters

    class TestClassDetector

      def self.test_classes_for(test_file)
        # TODO - I think this will fail if they have a file that doesn't define a new class
        # for instance, if they are adding methods to an existing test class
        old_test_classes = self.find_test_classes
        # require test_file
        # Tack::SandboxLoader.load(test_file)
        yield test_file if block_given?
        new_test_classes = self.find_test_classes
        new_test_classes - old_test_classes
      end

      def self.find_test_classes
        test_classes = []
        ObjectSpace.each_object(Class) do |klass|
          if(Test::Unit::TestCase > klass)
            test_classes << klass
          end
        end
        test_classes
      end
      
    end

  end

end
