EmopDashboard::Application.routes.draw do
   # juxta visualization routes
   get "juxta" => "juxta#show"
   post "juxta/upload_sources/:collation_id" => "juxta#upload_sources"

   # page results routes
   get "results" => "results#show"
   get "results/:work/page/:num" => "results#get_page_image"
   get "results/fetch" => "results#fetch"

   # main dashboard routes
   get "dashboard/index"
   get "dashboard/fetch"
   get "dashboard/batch/:id" => "dashboard#batch"

   # site root is the dashboard
   root :to => "dashboard#index"
end
