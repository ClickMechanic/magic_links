Rails.application.routes.draw do
  devise_for :users
  mount MagicLinks::Engine => "/magic_links"
end
