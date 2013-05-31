EmopDashboard::Application.routes.draw do
  get "page/:id" => "page_detail#show"

  get "dashboard/index"
  get "dashboard/fetch"

  root :to => "dashboard#index"
end
