require 'rails_helper'

RSpec.describe "PrintFont", :type => :request do
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
      get '/api/print_fonts', {}, api_headers
      expect(response).not_to be_success
    end
  end

  describe "GET /api/print_fonts" do
    it 'sends a list of print_fonts', :show_in_doc do
      create_list(:print_font, 2)
      get '/api/print_fonts', {}, api_headers

      expect(response).to be_success
      expect(json['results'].length).to eq(2)
    end
  end

  describe "GET /api/print_fonts/:id" do
    it 'retrieves a specific print_font', :show_in_doc do
      print_font = create(:print_font)
      get "/api/print_fonts/#{print_font.pf_id}", {}, api_headers

      expect(response).to be_success
      expect(json['print_font']['pf_name']).to eq(print_font.pf_name)
      expect(json['print_font']['pf_id']).to eq(print_font.pf_id)
    end
  end

  describe "POST /api/print_fonts" do
    it 'creates a print_font', :show_in_doc do
      @print_font = FactoryGirl.json(:print_font)
      expect {
        post "/api/print_fonts", @print_font, api_headers
      }.to change(PrintFont, :count).by(1)

      expect(response).to be_success
    end
  end
end
