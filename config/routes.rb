EmopDashboard::Application.routes.draw do
   # juxta visualization routes
   get "juxta" => "juxta#show"

   # page results routes
   get "results" => "results#show"
   get "results/:work/page/:num" => "results#get_page_image"
   get "results/fetch" => "results#fetch"

   # main dashboard routes
   get "dashboard/index"
   get "dashboard/fetch"
   get "dashboard/batch/:id" => "dashboard#batch"
   post "dashboard/batch" => "dashboard#create_batch"

   # site root is the dashboard
   root :to => "dashboard#index"
end
