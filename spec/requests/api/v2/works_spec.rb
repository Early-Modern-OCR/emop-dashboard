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
        get '/api/works', {is_eebo: 'foo'}, api_headers
        expect(response).not_to be_success
      end

      it 'validates is_ecco' do
        job_queues = create_list(:work, 2)
        get '/api/works', {is_ecco: 'foo'}, api_headers
        expect(response).not_to be_success
      end
    end

    it 'sends a paginated list of batch jobs' do
      work = FactoryGirl.create_list(:work, 30)
      get '/api/works', {}, api_headers

      expect(response).to be_success
      expect(json['subtotal']).to eq(25)
      expect(json['page']).to eq(1)
      expect(json['results'].length).to eq(25)
    end

    it 'sends a list of works', :show_in_doc do
      work = FactoryGirl.create_list(:work, 2)
      get '/api/works', {}, api_headers

      expect(response).to be_success
      expect(json['subtotal']).to eq(2)
      expect(json['page']).to eq(1)
      expect(json['results'].length).to eq(2)
    end

    it 'filters works using is_eebo' do
      create_list(:work, 2, collection: create(:works_collection, name: 'ECCO'))
      create_list(:work, 3, collection: create(:works_collection, name: 'EEBO'))
      get '/api/works', {is_eebo: true}, api_headers
      expect(json['results'].size).to eq(3)
    end

    it 'filters works using is_ecco' do
      create_list(:work, 2, collection: create(:works_collection, name: 'ECCO'))
      create_list(:work, 3, collection: create(:works_collection, name: 'EEBO'))
      get '/api/works', {is_ecco: true}, api_headers
      expect(json['results'].size).to eq(2)
    end

    it 'filters works using is_ecco' do
      create_list(:work, 2, collection: create(:works_collection, name: 'ECCO'))
      create_list(:work, 3, collection: create(:works_collection, name: 'EEBO'))
      get '/api/works', {is_ecco: false}, api_headers
      expect(json['results'].size).to eq(5)
    end

    context 'filters by batch_job_id' do
      before(:each) do
        @batch_job1 = create(:batch_job)
        @batch_job2 = create(:batch_job)
        (1..2).each do |i|
          work = create(:work)
          create(:job_queue, work: work, batch_job: @batch_job1)
        end
        (1..3).each do |i|
          work = create(:work)
          create(:job_queue, work: work, batch_job: @batch_job2)
        end
      end

      it 'filters works by batch_job_id' do
        get '/api/works', {batch_job_id: @batch_job1.id}, api_headers
        expect(json['results'].size).to eq(2)
      end

      it 'filters works by batch_job_id' do
        get '/api/works', {batch_job_id: @batch_job2.id}, api_headers
        expect(json['results'].size).to eq(3)
      end
    end
  end

  describe "GET /api/works/:id" do
    it 'retrieves a specific work', :show_in_doc do
      work = FactoryGirl.create(:work)
      get "/api/works/#{work.id}", {}, api_headers

      expect(response).to be_success
      expect(json['work']['wks_gt_number']).to eq(work.wks_gt_number)
    end
  end

  describe "POST /api/works" do
    it 'creates a work', :show_in_doc do
      works_collection = create(:works_collection)
      @work = FactoryGirl.json(:work, collection: works_collection)
      expect {
        post "/api/works", @work, api_headers
      }.to change(Work, :count).by(1)

      expect(response).to be_success
    end
  end

  describe "POST /api/works/create_bulk" do
    it 'creates works', :show_in_doc do
      @work1 = FactoryGirl.json(:work)
      @work2 = FactoryGirl.json(:work)
      data = {
        works: [JSON.parse(@work1), JSON.parse(@work2)],
      }
      expect {
        post "/api/works/create_bulk", data.to_json, api_headers
      }.to change(Work, :count).by(2)

      expect(response).to be_success
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

  describe "DELETE /api/works/:id" do
    it 'deletes a work', :show_in_doc do
      @work = create(:work)

      expect {
        delete "/api/works/#{@work.id}", {}, api_headers
      }.to change(Work, :count).by(-1)
      expect { Work.find(@work.id) }.to raise_exception(ActiveRecord::RecordNotFound)
    end
  end
end
