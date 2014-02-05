# config/routes/api/v1.rb

require 'api_constraints'

EmopDashboard::Application.routes.draw do

  namespace :api, :defaults => {:format => 'json'} do
    scope :module => :v1, constraints: ApiConstraints.new(version: 1, default: true) do

      resources :batch_jobs, :only => [:index,:show] do
        get 'first/:n', on: :collection, action: 'first'
 
        resources :job_queues, :only => [:index,:show]
      end

      resources :job_statuses, :only => [:index,:show] do
        get 'job_queues(/:limit)', on: :member, action: 'job_queues'
      end
    end
  end
end
