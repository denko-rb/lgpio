require_relative 'lib/lgpio/version'

Gem::Specification.new do |s|
  s.name        = 'lgpio'
  s.version     = LGPIO::VERSION
  s.licenses    = ['MIT']
  s.summary     = "Ruby C extension for Linux GPIO"
  s.description = "Use Linux GPIO, I2C, SPI and PWM in Ruby"

  s.authors     = ["vickash"]
  s.email       = 'mail@vickash.com'
  s.files       = `git ls-files`.split($\)
  s.homepage    = 'https://github.com/denko-rb/lgpio'
  s.metadata    = { "source_code_uri" => "https://github.com/denko-rb/lgpio" }

  s.required_ruby_version = '>=3'
  s.extensions = %w[ext/lgpio/extconf.rb]
end
