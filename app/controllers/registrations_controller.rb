class RegistrationsController < ApplicationController
  respond_to :json

  def create
    status, message = RegistrationService.new(params[:phone_number]).register_user
    standard_return(status, message)
  end

  def verify
    status, message, user_id, auth_token, new_user = RegistrationService.new(params[:phone_number], params[:verification_token]).verify_user

    respond_to do |format|
      if status
        format.json { render json: { message: '', success: true, authentication_token: auth_token, user_id: user_id, new_user: new_user }.to_json, status: 200 }
      else
        format.json { render json: { message: message, success: false }.to_json, status: 400 }
      end
    end
  end
end
