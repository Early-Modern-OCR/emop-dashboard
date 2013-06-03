EmopDashboard::Application.routes.draw do
  get "results" => "results#show"
  get "results/fetch" => "results#fetch"
  
  
  get "dashboard/index"
  get "dashboard/fetch"

  root :to => "dashboard#index"
end
