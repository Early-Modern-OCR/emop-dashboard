require 'rails_helper'

RSpec.describe Api::V1::PostprocPagesController, :type => :request do
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
      get '/api/postproc_pages', {}, api_headers
      expect(response).not_to be_success
    end
  end

  describe "GET /api/postproc_pages" do
    it 'sends a paginated list of postproc_page results' do
      postproc_pages = create_list(:postproc_page, 30)
      get '/api/postproc_pages', {}, api_headers

      expect(response).to be_success
      expect(json['total']).to eq(30)
      expect(json['subtotal']).to eq(25)
      expect(json['page']).to eq(1)
      expect(json['per_page']).to eq(25)
      expect(json['total_pages']).to eq(2)
      expect(json['results'].length).to eq(25)
    end

    it 'sends a list of postproc_page results', :show_in_doc do
      postproc_pages = create_list(:postproc_page, 2)
      get '/api/postproc_pages', {}, api_headers

      expect(response).to be_success
      expect(json['total']).to eq(2)
      expect(json['subtotal']).to eq(2)
      expect(json['page']).to eq(1)
      expect(json['per_page']).to eq(2)
      expect(json['total_pages']).to eq(1)
      expect(json['results'].length).to eq(2)
    end

    it 'return page results by batch_job_id' do
      create_list(:postproc_page, 2)
      batch_job = create(:batch_job)
      create_list(:postproc_page, 5, batch_job: batch_job)
      get '/api/postproc_pages', {batch_job_id: batch_job.id}, api_headers

      expect(response).to be_success
      expect(json['total']).to eq(5)
      expect(json['subtotal']).to eq(5)
      expect(json['page']).to eq(1)
      expect(json['per_page']).to eq(5)
      expect(json['total_pages']).to eq(1)
      expect(json['results'].length).to eq(5)
    end
  end

  describe "GET /api/postproc_pages/:id" do
    it 'retrieves a specific postproc_page result', :show_in_doc do
      postproc_page = create(:postproc_page)
      get "/api/postproc_pages/#{postproc_page.id}", {}, api_headers

      expect(response).to be_success
      expect(json['postproc_page']['id']).to eq(postproc_page.id)
    end
  end
end
