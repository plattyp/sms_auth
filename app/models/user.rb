class User < ActiveRecord::Base
  has_many :authentication_tokens, dependent: :destroy
  has_one :phone_verification, dependent: :destroy
end
