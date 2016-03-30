# encoding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "hydro_client"
  spec.version       = "2.3.5"
  spec.authors       = ["Juan Pablo Bochard"]
  spec.email         = ["jbochard@despegar.com"]
  spec.summary       = %q{Sistema de seguimiento de hidroponia}
  spec.description   = %q{Sistema de seguimiento de hidroponia}
  spec.homepage      = "https://github.com/despegar/hydroponic"
  spec.licenses      = "GPL-3.0"

  spec.files         = `find .  -type f -a ! -path "./config*" -a ! -path "./.git*" -a ! -name ".DS_Store" -a ! -name "*.gem" -a ! -path "./files*"`.split("\n").map {|k|  k.gsub("./", "") }
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler",      "~> 1.3"
  spec.add_development_dependency "rspec",        "~> 2.13"
  spec.add_development_dependency "byebug",       "~> 6.0"

  spec.add_runtime_dependency "hana",             "~> 1.3"
  spec.add_runtime_dependency "json",             "~> 1.8"
  spec.add_runtime_dependency "rest-client",      "~> 1.8"
  spec.add_runtime_dependency "thin",             "~> 1.6"
  spec.add_runtime_dependency "sinatra",          "~> 1.4"
  spec.add_runtime_dependency "sinatra-contrib",  "~> 1.4"
  spec.add_runtime_dependency "watir-webdriver",  "~> 0.8"
  spec.add_runtime_dependency "json-schema",      "~> 2.6"
  spec.add_runtime_dependency "serialport",       "~> 1.1"
end
