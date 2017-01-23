# SMS Auth

A Rails engine for quickly adding SMS authentication to a Rails API.

## Why use this?

This was originally built to support SMS authentication for a mobile application. It was later extracted into this engine so that it could be used easily for future apis. If you are interested in adding this type of authentication to your app, this should get you up and running in a few minutes without the need to use a Warden based solution.

## Installation

### Add the gem to you gemfile

    gem 'sms_auth'

### Run Bundle Install in the console

    bundle install

### Copy over the migrations

    rake sms_auth:install:migrations

### Setup the DB

    rake db:create db:migrate

### Configure the gem

Create an initializer called `config/initializers/sms_auth.rb` and set it up with your [Twilio](https://www.twilio.com) account information

```
require 'sms_auth'

SmsAuth::Engine.setup do |config|
  config.twilio_auth_token = 'AUTH TOKEN HERE'
  config.twilio_account_sid = 'ACCOUNT SID HERE'
  config.twilio_from_number = '+13122486863'
end

```

### Mount the Engine in your config/routes, add it at the top

```
Rails.application.routes.draw do
  mount SmsAuth::Engine => '/', as: 'auth'
end
```

### Update your controllers/application_controller to use the Auth Helper provided

```
class ApplicationController < ActionController::Base
  include SmsAuth::Engine::AuthControllerHelper
  protect_from_forgery with: :null_session
end
```
