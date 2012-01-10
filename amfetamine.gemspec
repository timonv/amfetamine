# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "amfetamine/version"

Gem::Specification.new do |s|
  s.name        = "Amfetamine"
  s.version     = Amfetamine::VERSION
  s.authors     = ["Timon Vonk"]
  s.email       = ["timon@exvo.com"]
  s.homepage    = "http://www.github.com/exvo/amfetamine"
  s.summary     = %q{Wraps REST to objects}
  s.description = %q{Wraps REST to objects, provides caching and makes your app go Bzzz!}

  s.rubyforge_project = "amfetamine"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # Development dependencies
  s.add_development_dependency "rspec"
  s.add_development_dependency "guard"
  s.add_development_dependency "guard-rspec"
  #s.add_development_dependency "growl_notify"
  #s.add_development_dependency "rb-fsevent"
  s.add_development_dependency "growl"
  s.add_development_dependency "httparty"
  s.add_development_dependency "fakeweb"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "simplecov-rcov"


  # Runtime dependencies
  s.add_runtime_dependency "dalli"
  s.add_runtime_dependency "activesupport" # For helper methods
  s.add_runtime_dependency "activemodel" # For validations and AM like behaviour
  s.add_runtime_dependency "json"
  s.add_runtime_dependency "rake"
end
