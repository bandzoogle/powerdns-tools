# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "powerdns-tools/version"

Gem::Specification.new do |s|
  s.name        = "powerdns-tools"
  s.version     = Powerdns::Tools::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Bandzoogle"]
  s.email       = ["colin@bandzoogle.com"]
  s.homepage    = "http://rubygems.org/gems/powerdns-tools"
  s.summary     = %q{library to interact with powerdns api service}
  s.description = %q{library to interact with powerdns api service}

  s.rubyforge_project = "powerdns-tools"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency('zonefile', "~> 1.04")
  s.add_dependency('activeresource', "~> 3.2.12")
  s.add_dependency('activesupport', "~> 3.2.12")
  s.add_dependency 'psych', "1.3.4"

  s.add_dependency("pry")

  s.add_development_dependency(%q<rake>, [">= 0"])
  s.add_development_dependency(%q<rspec>, [">= 2.12.0"])
  s.add_development_dependency(%q<rdoc>, [">= 0"])
  s.add_development_dependency(%q<vcr>, [">= 2.5.0"])
  s.add_development_dependency(%q<webmock>, ["1.11.0"])
  s.add_development_dependency(%q<simplecov>, [">= 0"])

end
