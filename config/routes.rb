EmopDashboard::Application.routes.draw do
  get "dashboard/index"
  get "dashboard/fetch"

  root :to => "dashboard#index"
end
