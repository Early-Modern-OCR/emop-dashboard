require 'rails_helper'

RSpec.describe "FontTrainingResult", :type => :request do
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
      get '/api/font_training_results', {}, api_headers
      expect(response).not_to be_success
    end
  end

  describe "GET /api/font_training_results" do
    it 'sends a list of works collections', :show_in_doc do
      create_list(:font_training_result, 2)
      get '/api/font_training_results', {}, api_headers

      expect(response).to be_success
      expect(json['results'].length).to eq(2)
    end
  end

  describe "GET /api/font_training_results/:id" do
    it 'retrieves a specific works collection', :show_in_doc do
      font_training_result = create(:font_training_result)
      get "/api/font_training_results/#{font_training_result.id}", {}, api_headers

      expect(response).to be_success
      expect(json['font_training_result']['font_path']).to eq(font_training_result.font_path)
      expect(json['font_training_result']['id']).to eq(font_training_result.id)
    end
  end
end
