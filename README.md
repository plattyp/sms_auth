# SMS Auth [![Build Status](https://travis-ci.org/plattyp/sms_auth.svg?branch=master)](https://travis-ci.org/plattyp/sms_auth) [![Code Climate](https://codeclimate.com/github/plattyp/sms_auth/badges/gpa.svg)](https://codeclimate.com/github/plattyp/sms_auth) [![Test Coverage](https://codeclimate.com/github/plattyp/sms_auth/badges/coverage.svg)](https://codeclimate.com/github/plattyp/sms_auth/coverage)

A Rails engine for quickly adding SMS authentication to a Rails API.

## What does this do?

It will let a user on your app authenticate with only their phone number. It'll provide them an authentication token that will be enforced on protected routes (described below). It will also provide user context on the protected routes.

This gem currently only supports PostgreSQL and creates 3 tables: `phone_verifications`, `authentication_tokens`, and `users` (it will skip this one if the table already exists)

## Why use this?

This was originally built to support SMS authentication for an API used for a mobile application. If you are interested in adding this type of authentication to your API, this should get you up and running in a few minutes without the need to use a Warden based solution. It will let you accomplish authentication on a mobile app with a flow similar to below

![blend authentication runthrough](https://cloud.githubusercontent.com/assets/5751986/22234028/7303c3d2-e1ba-11e6-9a64-43cd5e902ca5.gif)

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

Create an initializer called `config/initializers/sms_auth.rb` and set it up with your [Twilio](https://www.twilio.com) account information. You will need to purchase a phone number that can send text messages to use as your from.

```ruby
require 'sms_auth'

SmsAuth::Engine.setup do |config|
  config.twilio_auth_token = 'AUTH TOKEN HERE'
  config.twilio_account_sid = 'ACCOUNT SID HERE'
  config.twilio_from_number = 'FROM_PHONE_NUMBER'
end

```

### Mount the Engine in your config/routes, add it at the top

```ruby
Rails.application.routes.draw do
  mount SmsAuth::Engine => '/', as: 'auth'
end
```

### Update your controllers/application_controller to use the Auth Controller Helper provided

```ruby
class ApplicationController < ActionController::Base
  include SmsAuth::Engine::AuthControllerHelper
  protect_from_forgery with: :null_session
end
```

### If you have a specific controller that you want to be protected with authentication, use a before_filter

The `authenticate_with_token!` filter can be used on all controller methods or can be excluded to only specific ones.

```ruby
class ExampleController < ApplicationController
  before_action :authenticate_with_token!
  respond_to :json
end
```
For authenticated controllers, the `current_user` and `current_token` objects are defined to allow you to use that information in your endpoints.

## Configurable Options

Additional configuration options can be added within the initializer (as mentioned above). Here are the additional arguements allowed and what they do.

```ruby
require 'sms_auth'

SmsAuth::Engine.setup do |config|
  config.twilio_auth_token = 'AUTH TOKEN HERE'
  config.twilio_account_sid = 'ACCOUNT SID HERE'
  config.twilio_from_number = 'FROM_PHONE_NUMBER'
  config.max_login_attempts = 5
  config.max_login_attempt_within_minutes = 60
end

```

#### message_prefix (string)
It will append a prefix to SMS texts being sent out (e.g. if it is set to "Onboarding App", then the user would receive "Onboarding App: Your verification code is 123456"

#### token_length (int, defaults to 6)
It will set the token length that is sent to user to be a code that is N length.

#### max_login_attempts (int, defaults to 3)
Number of attempts allowed in the allotted time frame before the account is temporarily locked.

#### max_login_attempt_within_minutes (int, defaults to 15)
Is used to determine how many login attempts to consider when looking at recent tries. If a user tried to login 3 times in the last 15 minutes, then their account would be locked. If you set this number to 60, then it would be locked if they tried 3 unsuccessful times in the last 60 minutes.

#### verification_token_time_limit_minutes (int, defaults to 5)
If a token is sent out to a user and they wait longer than N minutes to verify it, then it will make them request another

#### lock_min_duration (int, defaults to 60)
If a user unsuccessfully verifies their token the maximum number of times within the allotted `max_login_attempt_within_minutes` then it will lock their account for N minutes.

#### default_token_expiration_days (int, defaults to 90)
When creating a new authentication_token, it will expire in 90 days. The protected endpoints will return a 401 if the token expired, so that you can then try to request a new one.

#### limited_recipients (array of strings, defaults to [])
If you are testing in an environment and would like to limit phone numbers that can authenticate to only specific phone numbers then set this as an array of numbers (e.g. ['3125552333','3123332255']) and only ones that are within this will be allowed to authenticate and receive the text verification code.

## Routes

This will mount 3 routes to your application: `/auth/login`, `/auth/verify`, and `/auth/logout`

#### POST `/auth/login?phone_number=312-555-2333`

This will cleanup the phone number and initiate the sending of the verification token to the SMS device

#### POST `/auth/verify?phone_number=312-555-2333&verification_token=680587`

After the device receives the verification_token, you will post to this endpoint with the phone_number and verification_token received via SMS. If successful, it will return this body:

```json
{
  "message": "",
  "success": true,
  "authentication_token": "mr-B9xBaHyJABkyR9jgq1FRs7zdZFE4VsFWR_J7y",
  "user_id": 1,
  "new_user": false
}
```
Store the `authentication_token` on the device and pass it in as `Authorization` within the header. If not provided on protected routes, it will not allow you to continue. `new_user` is true only if the user was just created on his/her first verification. At this point, you can redirect to pages that would enrich other parts of the `User` model.

#### DELETE `/auth/logout`

All authenticated routes (including logout) will require the `Authorization` added to the header.

### Error Handling

All endpoints will return a HTTP status code of 400 if there is an issue and return a `message` and `success` key within the json body to then be displayed to the Client. 

```json
{
  "message": "The verification token used is expired. Please request a new one and try again.",
  "success": false
}
```

If it succeeds, it will return a HTTP status code of 200 and both keys
```json
{
  "message": "",
  "success": true
}

```

