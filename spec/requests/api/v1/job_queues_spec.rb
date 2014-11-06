require 'rails_helper'

RSpec.describe "JobQueues", :type => :request do
  let(:api_headers) { {'Accept' => 'application/emop; version=1'} }

  describe "GET /api/job_queues" do
    it 'sends a list of job queues', :show_in_doc do
      FactoryGirl.create_list(:job_queue, 2)
      get '/api/job_queues', {}, api_headers

      expect(response).to be_success
      expect(json['results'].length).to eq(2)
    end
  end

  describe "GET /api/job_queues/:id" do
    it 'retrieves a specific job queue', :show_in_doc do
      job_queue = FactoryGirl.create(:job_queue)
      get "/api/job_queues/#{job_queue.id}", {}, api_headers

      expect(response).to be_success
      expect(json['job_queue']['results']).to eq(job_queue.results)
    end
  end
end
