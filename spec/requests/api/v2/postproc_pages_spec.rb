require 'rails_helper'

RSpec.describe Api::V2::PostprocPagesController, :type => :request do
  let(:api_headers) do
    {
      'Accept' => 'application/emop; version=2',
      'Authorization' => "Token token=#{User.first.auth_token}",
      'Content-Type' => 'application/json',
    }
  end

  describe "Unauthorized access" do
    let(:api_headers) do
      {
        'Accept' => 'application/emop; version=2',
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
      expect(json['total']).to be_nil #eq(30)
      expect(json['subtotal']).to eq(25)
      expect(json['page']).to eq(1)
      expect(json['per_page']).to be_nil #eq(25)
      expect(json['total_pages']).to be_nil #eq(2)
      expect(json['results'].length).to eq(25)
    end

    it 'sends a list of postproc_page results', :show_in_doc do
      postproc_pages = create_list(:postproc_page, 2)
      get '/api/postproc_pages', {}, api_headers

      expect(response).to be_success
      expect(json['total']).to be_nil #eq(2)
      expect(json['subtotal']).to eq(2)
      expect(json['page']).to eq(1)
      expect(json['per_page']).to be_nil #eq(2)
      expect(json['total_pages']).to be_nil #eq(1)
      expect(json['results'].length).to eq(2)
    end

    it 'return page results by batch_job_id' do
      create_list(:postproc_page, 2)
      batch_job = create(:batch_job)
      create_list(:postproc_page, 5, batch_job: batch_job)
      get '/api/postproc_pages', {batch_job_id: batch_job.id}, api_headers

      expect(response).to be_success
      expect(json['total']).to be_nil #eq(5)
      expect(json['subtotal']).to eq(5)
      expect(json['page']).to eq(1)
      expect(json['per_page']).to be_nil #eq(5)
      expect(json['total_pages']).to be_nil #eq(1)
      expect(json['results'].length).to eq(5)
    end

    it 'returns association data' do
      work = create(:work)
      page = create(:page, work: work)
      create(:postproc_page, page: page)

      get '/api/postproc_pages', {}, api_headers

      expect(json['results'][0]['work_id']).to eq(work.id)
    end

    it 'filters by wks_work_id', :show_in_doc do
      work = create(:work)
      page = create(:page, work: work)
      create_list(:postproc_page, 2)
      postproc_pages = create_list(:postproc_page, 3, page: page)
      get '/api/postproc_pages', {works: {wks_work_id: work.id}}, api_headers

      expect(json['results'].size).to eq(postproc_pages.size)
    end

    it 'does not include page data' do
      work = create(:work)
      page = create(:page, work: work)
      create(:postproc_page, page: page)

      get '/api/postproc_pages', {}, api_headers

      expect(json['results'][0]['page']).to be_nil
    end

    it 'returns page details', :show_in_doc do
      work = create(:work)
      page = create(:page, work: work)
      create(:postproc_page, page: page)

      get '/api/postproc_pages', {page_details: true}, api_headers

      expect(json['results'][0]['page']).to be_a(Hash)
      expect(json['results'][0]['page']['id']).to eq(page.id)
    end
  end

  describe "GET /api/postproc_pages/:id" do
    it 'retrieves a specific postproc_page result', :show_in_doc do
      postproc_page = create(:postproc_page)
      get "/api/postproc_pages/#{postproc_page.id}", {}, api_headers

      expect(response).to be_success
      expect(json['postproc_page']['id']).to eq(postproc_page.id)
    end

    it 'returns association data' do
      work = create(:work)
      page = create(:page, work: work)
      postproc_page = create(:postproc_page, page: page)

      get "/api/postproc_pages/#{postproc_page.id}", {}, api_headers

      expect(json['postproc_page']['work_id']).to eq(work.id)
    end
  end
end
