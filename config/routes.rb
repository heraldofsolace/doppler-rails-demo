Rails.application.routes.draw do
  get '/demo', to: 'demo#index'
  root 'demo#index'
end
