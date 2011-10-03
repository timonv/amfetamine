# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "dada/version"

Gem::Specification.new do |s|
  s.name        = "Dada"
  s.version     = Dada::VERSION
  s.authors     = ["Timon Vonk @ Exvo"]
  s.email       = ["timon@exvo.com"]
  s.homepage    = "http://www.github.com/exvo/dada"
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "dada"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # Development dependencies
  s.add_development_dependency "rspec"
  s.add_development_dependency "guard"
  s.add_development_dependency "guard-rspec"
  #s.add_development_dependency "growl_notify"
  s.add_development_dependency "rb-fsevent"
  s.add_development_dependency "growl"
  s.add_development_dependency "httparty"
  s.add_development_dependency "fakeweb"


  # Runtime dependencies
  s.add_runtime_dependency "dalli"
  s.add_runtime_dependency "yard"
  s.add_runtime_dependency "active_support", ">= 3.0" # For helper methods
end
