Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  devise_for :users, skip: [:registration]
  # API docs
  apipie

  # API routes
  namespace :api, defaults: {format: 'json'} do
    api_version(module: "V1", defaults: {format: :json}, header: {name: "Accept", value: "application/emop; version=1"}, default: true) do
      resources :batch_jobs, only: [:index,:show] do
        get 'count', on: :collection
      end
      resources :job_queues, only: [:index,:show] do
        get 'count', on: :collection
        put 'reserve', on: :collection
      end
      resources :job_statuses, only: [:index,:show]
    end
  end

  # create a new training font
  post "fonts/training_font" => "fonts#create_training_font"
  post "fonts/print_font" => "fonts#set_print_font"

   # juxta visualization routes
   get "juxta" => "juxta#show"

   # page results routes
   get "results" => "results#show"
   get "results/:work/page/:num" => "results#get_page_image"
   get "results/fetch" => "results#fetch"
   post "results/batch" => "results#create_batch"
   get "results/:id/text" => "results#get_page_text"
   get "results/:id/hocr" => "results#get_page_hocr"
   get "results/:batch/:page/error" => "results#get_page_error"
   post "results/reschedule" => "results#reschedule"

   # main dashboard routes
   get "dashboard/index"
   get "dashboard/fetch"
   get "dashboard/export"
   get "dashboard/batch/:id" => "dashboard#batch"
   post "dashboard/batch" => "dashboard#create_batch"
   post "dashboard/reschedule" => "dashboard#reschedule"
   get "dashboard/:batch/:work/error" => "dashboard#get_work_errors"

   # site root is the dashboard
   root to: "dashboard#index"

   # for testing the server setup
   get "/test_exception_notifier" => "dashboard#test_exception_notifier"

end
