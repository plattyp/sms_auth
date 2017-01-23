class TokensController < ApplicationController
  before_action :authenticate_with_token!
  respond_to :json

  def logout
    status, message = TokenService.new(current_token).logout
    standard_return(status, message)
  end
end
