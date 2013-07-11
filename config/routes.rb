EmopDashboard::Application.routes.draw do
  # create a new training font
  resources :fonts

   # juxta visualization routes
   get "juxta" => "juxta#show"

   # page results routes
   get "results" => "results#show"
   get "results/:work/page/:num" => "results#get_page_image"
   get "results/fetch" => "results#fetch"
   post "results/batch" => "results#create_batch"
   get "results/:id/text" => "results#get_page_text"
   get "results/:batch/:page/error" => "results#get_page_error"

   # main dashboard routes
   get "dashboard/index"
   get "dashboard/fetch"
   get "dashboard/batch/:id" => "dashboard#batch"
   post "dashboard/batch" => "dashboard#create_batch"
   get "dashboard/:batch/:work/error" => "dashboard#get_work_errors"

   # site root is the dashboard
   root :to => "dashboard#index"
end
