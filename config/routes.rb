Rails.application.routes.draw do
  post 'auth/login', to: 'registrations#create'
  post 'auth/verify', to: 'registrations#verify'
  delete 'auth/logout', to: 'tokens#logout'
end
