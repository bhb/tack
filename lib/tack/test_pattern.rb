module Tack

  class TestPattern < Regexp

    DEFAULT = /.*/

    def initialize(pattern=nil)
      pattern = case pattern
                when nil:
                    DEFAULT
                when String, Regexp:
                    pattern
                else
                  DEFAULT
                end
      super(pattern)
    end

  end

end
