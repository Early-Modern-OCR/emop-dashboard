require 'rails_helper'

RSpec.describe Api::V2::PagesController, :type => :request do
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
      get '/api/pages', {}, api_headers
      expect(response).not_to be_success
    end
  end

  describe "GET /api/pages" do
    it 'sends a paginated list of batch jobs' do
      page = create_list(:page, 30)
      get '/api/pages', {}, api_headers

      expect(response).to be_success
      expect(json['total']).to be_nil #eq(30)
      expect(json['subtotal']).to eq(25)
      expect(json['page']).to eq(1)
      expect(json['per_page']).to be_nil #eq(25)
      expect(json['total_pages']).to be_nil #eq(2)
      expect(json['results'].length).to eq(25)
    end

    it 'respects per_page param' do
      page = create_list(:page, 30)
      get '/api/pages', {per_page: 30}, api_headers

      expect(response).to be_success
      expect(json['total']).to be_nil #eq(30)
      expect(json['subtotal']).to eq(30)
      expect(json['page']).to eq(1)
      expect(json['per_page']).to be_nil #eq(30)
      expect(json['total_pages']).to be_nil #eq(1)
      expect(json['results'].length).to eq(30)
    end

    it 'sends a list of pages', :show_in_doc do
      page = create_list(:page, 2)
      get '/api/pages', {}, api_headers

      expect(response).to be_success
      expect(json['total']).to be_nil # eq(2)
      expect(json['subtotal']).to eq(2)
      expect(json['page']).to eq(1)
      expect(json['per_page']).to be_nil # eq(2)
      expect(json['total_pages']).to be_nil #eq(1)
      expect(json['results'].length).to eq(2)
    end

    it 'filters by pg_image_path when pg_image_path is nil as string' do
      pages = build_list(:page, 2, pg_image_path: nil)
      pages.each do |p|
        p.save(validate: false)
      end
      create_list(:page, 3)
      query_params = { pg_image_path: 'nil' }
      get '/api/pages', query_params, api_headers

      expect(response).to be_success
      expect(json['total']).to be_nil # eq(2)
      expect(json['subtotal']).to eq(2)
      expect(json['page']).to eq(1)
      expect(json['per_page']).to be_nil # eq(2)
      expect(json['total_pages']).to be_nil #eq(1)
      expect(json['results'].length).to eq(2)
    end
  end

  describe "GET /api/pages/:id" do
    it 'retrieves a specific page', :show_in_doc do
      page = create(:page)
      get "/api/pages/#{page.id}", {}, api_headers

      expect(response).to be_success
      expect(json['page']['id']).to eq(page.id)
    end
  end

  describe "POST /api/pages" do
    it 'creates a page', :show_in_doc do
      @work = create(:work)
      @page = FactoryGirl.json(:page, pg_work_id: @work.id)
      expect {
        post "/api/pages", @page, api_headers
      }.to change(Page, :count).by(1)

      expect(response).to be_success
    end
  end

  describe "POST /api/pages/create_bulk" do
    it 'creates pages', :show_in_doc do
      @work = create(:work)
      # pg_ref_number #1 taken when work created
      @page1 = FactoryGirl.json(:page, pg_work_id: @work.id, pg_ref_number: 2)
      @page2 = FactoryGirl.json(:page, pg_work_id: @work.id, pg_ref_number: 3)
      data = {
        pages: [JSON.parse(@page1), JSON.parse(@page2)],
      }
      expect {
        post "/api/pages/create_bulk", data.to_json, api_headers
      }.to change(Page, :count).by(2)

      expect(json["pages"]["imported"]).to eq(2)
      expect(response).to be_success
    end
  end

  describe "PUT /api/pages/:id" do
    it 'updates a page', :show_in_doc do
      @page = create(:page)

      data = {
        page: {
          pg_image_path: '/foo/bar',
        },
      }

      put "/api/pages/#{@page.id}", data.to_json, api_headers

      expect(response).to be_success
      expect(json['page']['pg_image_path']).to eq('/foo/bar')
    end
  end

  describe "DELETE /api/pages/:id" do
    it 'deletes a page', :show_in_doc do
      @page = create(:page)

      expect {
        delete "/api/pages/#{@page.id}", {}, api_headers
      }.to change(Page, :count).by(-1)
      expect { Page.find(@page.id) }.to raise_exception(ActiveRecord::RecordNotFound)
    end
  end
end
