Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  
  resource :wechat, only: [:show, :create]

  # Background
  get '/admin/gmbuaa', to: 'admin#gmbuaa'
  post '/admin/gmbuaa', to: 'admin#gmupload' 
  get '/admin/gmbuaa/delete/:filename', to: 'admin#gmdelete'
  get '/admin/degists', to: 'admin#degists'
  # Canteen activity
  get '/canteen/:degist', to: 'canteen#use'

end
