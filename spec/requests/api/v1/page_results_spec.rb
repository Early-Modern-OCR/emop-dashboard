require 'rails_helper'

RSpec.describe Api::V1::PageResultsController, :type => :request do
  let(:api_headers) do
    {
      'Accept' => 'application/emop; version=1',
      'Authorization' => "Token token=#{User.first.auth_token}",
      'Content-Type' => 'application/json',
    }
  end

  describe "Unauthorized access" do
    let(:api_headers) do
      {
        'Accept' => 'application/emop; version=1',
      }
    end

    it 'should not be successful' do
      get '/api/page_results', {}, api_headers
      expect(response).not_to be_success
    end
  end

  describe "GET /api/page_results" do
    it 'sends a paginated list of page results' do
      page_results = create_list(:page_result, 30)
      get '/api/page_results', {}, api_headers

      expect(response).to be_success
      expect(json['total']).to eq(30)
      expect(json['subtotal']).to eq(25)
      expect(json['page']).to eq(1)
      expect(json['per_page']).to eq(25)
      expect(json['total_pages']).to eq(2)
      expect(json['results'].length).to eq(25)
    end

    it 'sends a list of page results', :show_in_doc do
      page_results = create_list(:page_result, 2)
      get '/api/page_results', {}, api_headers

      expect(response).to be_success
      expect(json['total']).to eq(2)
      expect(json['subtotal']).to eq(2)
      expect(json['page']).to eq(1)
      expect(json['per_page']).to eq(2)
      expect(json['total_pages']).to eq(1)
      expect(json['results'].length).to eq(2)
    end

    it 'return page results by batch_id' do
      create_list(:page_result, 2)
      batch_job = create(:batch_job)
      create_list(:page_result, 5, batch_job: batch_job)
      get '/api/page_results', {batch_id: batch_job.id}, api_headers

      expect(response).to be_success
      expect(json['total']).to eq(5)
      expect(json['subtotal']).to eq(5)
      expect(json['page']).to eq(1)
      expect(json['per_page']).to eq(5)
      expect(json['total_pages']).to eq(1)
      expect(json['results'].length).to eq(5)
    end

    it 'returns association data' do
      work = create(:work)
      page = create(:page, work: work)
      create(:page_result, page: page)

      get '/api/page_results', {}, api_headers

      expect(json['results'][0]['work_id']).to eq(work.id)
    end
  end

  describe "GET /api/page_results/:id" do
    it 'retrieves a specific page result', :show_in_doc do
      page_result = create(:page_result)
      get "/api/page_results/#{page_result.id}", {}, api_headers

      expect(response).to be_success
      expect(json['page_result']['id']).to eq(page_result.id)
    end

    it 'returns association data' do
      work = create(:work)
      page = create(:page, work: work)
      page_result = create(:page_result, page: page)

      get "/api/page_results/#{page_result.id}", {}, api_headers

      expect(json['page_result']['work_id']).to eq(work.id)
    end
  end
end
