Qb::Application.routes.draw do
  match 'questions/import' => 'questions#import'
  resources :questions

  delete '/attachments/:id' => 'attachments#delete'

  authenticated :user do
    root :to => 'home#index'
  end
  root :to => "home#index"
  devise_for :users
  resources :users, :only => [:show, :index]
end
