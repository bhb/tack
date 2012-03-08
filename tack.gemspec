# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "tack/version"

Gem::Specification.new do |s|
  s.name        = "tack"
  s.version     = Tack::VERSION
  s.authors     = ["Ben Brinckerhoff"]
  s.email       = ["ben@bbrinck.com"]
  s.homepage    = ""
  s.summary = %q{A Rack-inspired interface for testing libraries}
  s.description = %q{A Rack-inspired interface for testing libraries}

  s.rubyforge_project = "tack"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  s.add_development_dependency "shoulda"
  s.add_development_dependency "mocha"
  s.add_development_dependency "test-construct"
  s.add_development_dependency "machinist"
  s.add_development_dependency "rspec"
  s.add_development_dependency "rake"

  # s.add_runtime_dependency "rest-client"
  s.add_runtime_dependency "forkoff"
  s.add_runtime_dependency "facter"
end
