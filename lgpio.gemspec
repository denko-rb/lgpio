require_relative 'lib/lgpio/version'

Gem::Specification.new do |s|
  s.name        = 'lgpio'
  s.version     = LGPIO::VERSION
  s.licenses    = ['MIT']
  s.summary     = "Use Linux GPIO, I2C, SPI and PWM in Ruby"
  s.description = "Use Linux GPIO, I2C, SPI and PWM in Ruby"

  s.authors     = ["vickash"]
  s.email       = 'mail@vickash.com'
  s.files       = `git ls-files`.split($\)
  s.homepage    = 'https://github.com/denko-rb/lgpio'
  s.metadata    = { "source_code_uri" => "https://github.com/denko-rb/lgpio" }

  s.extensions = %w[ext/lgpio/extconf.rb]
end
