require 'rails_helper'

RSpec.describe Api::V2::WorksController, :type => :request do
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
      get '/api/works', {}, api_headers
      expect(response).not_to be_success
    end
  end

  describe "GET /api/works" do
    context 'validations' do
      it 'validates is_eebo' do
        job_queues = create_list(:work, 2)
        get '/api/works', {is_eebo: '1'}, api_headers
        expect(response).not_to be_success
      end

      it 'validates is_ecco' do
        job_queues = create_list(:work, 2)
        get '/api/works', {is_ecco: '1'}, api_headers
        expect(response).not_to be_success
      end
    end

    it 'sends a paginated list of batch jobs' do
      work = FactoryGirl.create_list(:work, 30)
      get '/api/works', {}, api_headers

      expect(response).to be_success
      expect(json['total']).to eq(30)
      expect(json['subtotal']).to eq(25)
      expect(json['page']).to eq(1)
      expect(json['per_page']).to eq(25)
      expect(json['total_pages']).to eq(2)
      expect(json['results'].length).to eq(25)
    end

    it 'sends a list of works', :show_in_doc do
      work = FactoryGirl.create_list(:work, 2)
      get '/api/works', {}, api_headers

      expect(response).to be_success
      expect(json['total']).to eq(2)
      expect(json['subtotal']).to eq(2)
      expect(json['page']).to eq(1)
      expect(json['per_page']).to eq(2)
      expect(json['total_pages']).to eq(1)
      expect(json['results'].length).to eq(2)
    end

    it 'filters works using is_eebo' do
      create_list(:work, 2)
      create_list(:work, 3, wks_ecco_number: nil)

      get '/api/works', {is_eebo: true}, api_headers

      expect(json['results'].size).to eq(3)
    end

    it 'filters works using is_ecco' do
      create_list(:work, 2)
      create_list(:work, 3, wks_ecco_number: nil)

      get '/api/works', {is_ecco: true}, api_headers

      expect(json['results'].size).to eq(2)
    end
  end

  describe "GET /api/works/:id" do
    it 'retrieves a specific work', :show_in_doc do
      work = FactoryGirl.create(:work)
      get "/api/works/#{work.id}", {}, api_headers

      expect(response).to be_success
      expect(json['work']['wks_tcp_number']).to eq(work.wks_tcp_number)
    end
  end

  describe "PUT /api/works/update" do
    it 'updates a work', :show_in_doc do
      @work = create(:work)

      data = {
        work: {
          wks_estc_number: 'T0001',
        },
      }

      put "/api/works/#{@work.id}", data.to_json, api_headers

      expect(response).to be_success
      expect(json['work']['wks_estc_number']).to eq('T0001')
    end
  end
end
