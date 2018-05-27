Rails.application.routes.draw do
  root "curators#index"
  get 'curators' => "curators#index"
  post "create" => "curators#create"
  post "cron" => "curators#cron"

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
