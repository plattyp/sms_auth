$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'sms_auth/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'sms_auth'
  s.version     = SmsAuth::VERSION
  s.authors     = ['Andrew Platkin']
  s.email       = ['andrew.platkin@gmail.com']
  s.homepage    = 'https://github.com/plattyp/sms_auth'
  s.summary     = 'A Rails engine for quickly adding SMS authentication to a Rails API'
  s.description = 'A Rails engine for quickly adding SMS authentication to a Rails API'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.rdoc']

  s.add_dependency 'rails', '~> 4.2.7.1'
  s.add_dependency 'twilio-ruby', '~> 4.11.1'
  s.add_dependency 'pg'
  s.add_dependency 'responders', '~> 2.0'

  s.add_development_dependency 'railties'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'faker'
  s.add_development_dependency 'factory_girl_rails'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'timecop'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'codeclimate-test-reporter', '~> 1.0.0'
end
