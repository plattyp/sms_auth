module AuthControllerHelper
  def current_user
    @current_user ||= AuthenticationToken.find_user_by_token(current_token)
  end

  def current_token
    @current_token ||= request.headers['Authorization']
  end

  def authenticate_with_token!
    render json: { errors: 'Endpoint requires authentication' }, status: :unauthorized unless user_signed_in?
  end

  def user_signed_in?
    current_user.present?
  end

  def standard_return(status, message)
    respond_to do |format|
      if status
        format.json { render json: { message: '', success: true }.to_json, status: 200 }
      else
        format.json { render json: { message: message, success: false }.to_json, status: 400 }
      end
    end
  end
end
