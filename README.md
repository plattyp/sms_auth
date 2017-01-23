# SMS Auth

A Rails engine for quickly adding SMS authentication to a Rails API.

## What does this do?

It will let a user on your app authenticate with only their phone number. It'll provide them an authentication token that will be enforced on protected routes (described below). It will also provide user context on the protected routes.

This gem currently only supports PostgreSQL and creates 3 tables: `phone_verifications`, `authentication_tokens`, and `users` (it will skip this one if the table already exists)

## Why use this?

This was originally built to support SMS authentication for an API used for a mobile application. If you are interested in adding this type of authentication to your API, this should get you up and running in a few minutes without the need to use a Warden based solution.

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

### Update your controllers/application_controller to use the Auth Controller Helper provided

```
class ApplicationController < ActionController::Base
  include SmsAuth::Engine::AuthControllerHelper
  protect_from_forgery with: :null_session
end
```

### If you have a specific controller that you want to be protected with authentication, use a before_filter

The `authenticate_with_token!` filter can be used on all controller methods or can be excluded to only specific ones.

```
class ExampleController < ApplicationController
  before_action :authenticate_with_token!
  respond_to :json
end
```
For authenticated controllers, the `current_user` and `current_token` objects are defined to allow you to use that information in your endpoints.

## Configurable Options

More info coming soon
