require 'rails_helper'

RSpec.describe "WorksCollections", :type => :request do
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
      get '/api/works_collections', {}, api_headers
      expect(response).not_to be_success
    end
  end

  describe "GET /api/works_collections" do
    it 'sends a list of works collections', :show_in_doc do
      create_list(:works_collection, 2)
      get '/api/works_collections', {}, api_headers

      expect(response).to be_success
      expect(json['results'].length).to eq(2)
    end
  end

  describe "GET /api/works_collections/:id" do
    it 'retrieves a specific works collection', :show_in_doc do
      works_collection = create(:works_collection)
      get "/api/works_collections/#{works_collection.id}", {}, api_headers

      expect(response).to be_success
      expect(json['works_collection']['name']).to eq(works_collection.name)
      expect(json['works_collection']['id']).to eq(works_collection.id)
    end
  end

  describe "POST /api/works_collections" do
    it 'creates a works collection', :show_in_doc do
      @works_collection = FactoryGirl.json(:works_collection)
      expect {
        post "/api/works_collections", @works_collection, api_headers
      }.to change(WorksCollection, :count).by(1)

      expect(response).to be_success
    end
  end
end
