require 'rails_helper'

RSpec.describe "Languages", :type => :request do
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
      get '/api/languages', {}, api_headers
      expect(response).not_to be_success
    end
  end

  describe "GET /api/languages" do
    it 'sends a list of languages', :show_in_doc do
      create_list(:language, 2)
      get '/api/languages', {}, api_headers

      expect(response).to be_success
      expect(json['results'].length).to eq(2)
    end
  end

  describe "GET /api/languages/:id" do
    it 'retrieves a specific language', :show_in_doc do
      language = create(:language)
      get "/api/languages/#{language.id}", {}, api_headers

      expect(response).to be_success
      expect(json['language']['name']).to eq(language.name)
      expect(json['language']['id']).to eq(language.id)
    end
  end

  describe "POST /api/languages" do
    it 'creates a language', :show_in_doc do
      @language = FactoryGirl.json(:language)
      expect {
        post "/api/languages", @language, api_headers
      }.to change(Language, :count).by(1)

      expect(response).to be_success
    end
  end
end
