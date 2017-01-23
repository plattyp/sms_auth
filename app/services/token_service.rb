class TokenService
  attr_reader :token_body

  def initialize(token_body)
    @token_body = token_body
  end

  def logout
    token = AuthenticationToken.find_by_body(token_body)
    return [false, 'Authentication token could not be found'] if token.nil?
    token.soft_delete
    [true, '']
  end
end
