Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  
  resource :wechat, only: [:show, :create]
  get '/canteen/use/:degist', to: 'canteen#use'

end
