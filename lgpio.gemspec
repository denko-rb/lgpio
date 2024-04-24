require_relative 'lib/lgpio/version'

Gem::Specification.new do |s|
  s.name        = 'lgpio'
  s.version     = LGPIO::VERSION
  s.licenses    = ['MIT']
  s.summary     = "lgpio (lg) bindings for Ruby"
  s.description = "Use GPIO / PWM / I2C / SPI / UART on Linux SBCs in Ruby"

  s.authors     = ["vickash"]
  s.email       = 'mail@vickash.com'
  s.files       = `git ls-files`.split($\)
  s.homepage    = 'https://github.com/denko-rb/lgpio'
  s.metadata    = { "source_code_uri" => "https://github.com/denko-rb/lgpio" }

  s.extensions = %w[ext/lgpio/extconf.rb]
end
