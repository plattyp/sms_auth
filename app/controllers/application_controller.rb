class ApplicationController < ActionController::Base
  include SmsAuth::Engine::AuthControllerHelper
  protect_from_forgery with: :null_session
end
