# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'transcribeme_motion/version'

Gem::Specification.new do |spec|
  spec.name          = 'transcribeme_motion'
  spec.version       = TranscribeMeMotion::VERSION
  spec.authors       = ['Caleb Tutty']
  spec.email         = ['caleb@prettymint.co.nz']
  spec.description   = 'TranscribeMe SOAP API wrapper for RubyMotion'
  spec.summary       = 'Using async NSURLConnection APIs from BubbleWrap to use the TranscribeMe API in RubyMotion projects'
  spec.homepage      = "http://tuttinator.github.io/transcribeme_motion/"
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'bubble-wrap', '~> 1.3.0'
  spec.add_development_dependency 'rake'
end
