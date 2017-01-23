# SMS Auth

An engine for quickly adding SMS authentication to a Rails app

## Installation

### Add the gem to you gemfile

    gem 'sms_auth'

### Copy over the migrations

    rake sms_auth:install_migrations

### Setup the DB

    rake db:create db:migrate

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
