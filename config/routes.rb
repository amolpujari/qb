Qb::Application.routes.draw do
  get '/questions/tagged'       => 'questions#index'
  resources :questions

  delete '/attachments/:id' => 'attachments#delete'

  authenticated :user do
    root :to => 'home#index'
  end
  root :to => "home#index"
  devise_for :users
  resources :users, :only => [:show, :index]
end
