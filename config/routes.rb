EmopDashboard::Application.routes.draw do
  get "results" => "results#show"
  get "results/:work/page/:num" => "results#get_page_image"
  get "results/fetch" => "results#fetch"
  
  
  get "dashboard/index"
  get "dashboard/fetch"
  get "dashboard/batch/:id" => "dashboard#batch"

  root :to => "dashboard#index"
end
