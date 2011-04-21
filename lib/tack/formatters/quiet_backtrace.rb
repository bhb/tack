# This code is from
# http://github.com/thoughtbot/quietbacktrace.git
# Dan Croak deserves the credit, not me. However, I couldn't
# find an up-to-date gem published anywhere, so inlined the
# code

module Tack

  module Formatters

    module QuietBacktrace
      class BacktraceCleaner
        
        RUBY_NOISE       = %w( ruby Ruby.framework 
                           rubygems/custom_require benchmark.rb )
        #TEST_UNIT_NOISE  = %w( test/unit )
        TEST_UNIT_NOISE  = [%r{[^\.]/test/unit}]
        GEM_NOISE        = %w( -e:1 )

        SHOULDA_NOISE    = %w( lib/shoulda )

        RAILS_NOISE = %w( script/server lib/active_record )
        VENDOR_DIRS = %w( vendor/gems vendor/rails vendor/plugins )
        SERVER_DIRS = %w( lib/mongrel bin/mongrel
                      lib/passenger bin/passenger-spawn-server
                      lib/rack )
        
        ERB_METHOD_SIG = /:in `_run_erb_.*/
        
        ALL_NOISE = RUBY_NOISE  + TEST_UNIT_NOISE + GEM_NOISE + SHOULDA_NOISE +
          RAILS_NOISE + VENDOR_DIRS     + SERVER_DIRS 
        
        def initialize
          @filters, @silencers = [], []

          if defined?(Rails) && Rails.root
            rails_root = Rails.root

          elsif defined?(RAILS_ROOT)
            rails_root = RAILS_ROOT
          end
          if rails_root
            add_filter { |line| line.sub("#{rails_root}/", '') }
          end

          
          add_filter { |line| line.sub(ERB_METHOD_SIG, '') }
          # add_filter { |line| line.sub('./', '/') }
          
          if defined?(Gem)
            add_filter do |line| 
              line.sub(/(#{Gem.default_dir})\/gems\/([a-z]+)-([0-9.]+)\/(.*)/, '\2 (\3) \4') 
            end
          end

          add_silencer { |line| ALL_NOISE.any? { |dir| line=~(Regexp.new(dir)) } }
        end
        
        # Returns the backtrace after all filters and silencers has been run against it. 
        # Filters run first, then silencers.
        def clean(backtrace)
          silence(filter(backtrace))
        end
        
        # Adds a filter from the block provided. 
        # Each line in the backtrace will be mapped against this filter.
        #
        # Example:
        #
        # Will turn "/my/rails/root/app/models/person.rb" into "/app/models/person.rb"
        # 
        # backtrace_cleaner = QuietBacktrace.BacktraceCleaner.new
        # backtrace_cleaner.add_filter { |line| line.gsub(Rails.root, '') }
        def add_filter(&block)
          @filters << block
        end
        
        # Adds a silencer from the block provided. If the silencer returns true for a given line, it'll be excluded from the
        # quiet backtrace.
        #
        # Example:
        #
        # Will reject all lines that include the word "mongrel", 
        # like "/gems/mongrel/server.rb" or "/app/my_mongrel_server/rb"
        # 
        # backtrace_cleaner = QuietBacktrace.BacktraceCleaner.new
        # backtrace_cleaner.add_silencer { |line| line =~ /mongrel/ }
        def add_silencer(&block)
          @silencers << block
        end
        
        # Will remove all silencers, but leave in the filters. 
        # This is useful if your context of debugging suddenly expands as
        # you suspect a bug in the libraries you use.
        def remove_silencers!
          @silencers = []
        end
        
        private
        
        def filter(backtrace)
          @filters.each do |f|
            backtrace = backtrace.map { |line| f.call(line) }
          end
          
          backtrace
        end
        
        def silence(backtrace)
          @silencers.each do |s|
            backtrace = backtrace.reject { |line| s.call(line) }
          end
          
          backtrace
        end

      end
    end

  end

end
