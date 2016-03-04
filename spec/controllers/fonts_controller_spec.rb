require 'rails_helper'

RSpec.describe FontsController, :type => :controller do

  let(:valid_session) { {} }

  describe "POST create_training_font" do
    before(:each) do
      @file = fixture_file_upload('files/eng.traineddata', 'application/octet-stream')
      class << @file
        # The reader method is present in a real invocation,
        # but missing from the fixture object for some reason.
        attr_reader :tempfile
      end
      # Mock the emop_font_dir path
      @font_dir = Dir.mktmpdir
      allow(Rails.application.secrets).to receive(:emop_font_dir) { @font_dir }
      allow(Settings).to receive(:font_suffix) { ".traineddata" }
      @params = {
        'font-name' => 'eng',
        file: @file,
      }
      @saved_file = File.join(@font_dir, "#{@params['font-name']}.traineddata")
    end

    it "should create new training font" do
      post :create_training_font, @params

      expect(response).to be_success

      font = Font.find_by(font_name: @params['font-name'])
      expect(font.name).to eq(@params['font-name'])
      expect(font.font_library_path).to be_nil
    end

    it "should write uploaded file" do
      post :create_training_font, @params

      expect(response).to be_success
      expect(File.exists?(@saved_file)).to be true
    end

    it "should not save if font_name exists" do
      create(:font, font_name: 'eng')

      post :create_training_font, @params

      expect(response).to_not be_success
    end

    it "should handle exception when file not set" do
      @params[:file] = nil

      post :create_training_font, @params

      expect(response).to_not be_success
    end
  end

  describe "POST set_print_font" do
    before(:each) do
      @print_font = create(:print_font)
      @works = create_list(:work, 2)
      @params = {
        works: @works.map(&:id).to_json,
        font_id: @print_font.id,
      }
    end

    it "should update works print font" do
      post :set_print_font, @params

      expect(response).to be_success

      works = Work.where(wks_primary_print_font: @print_font.id)
      expect(works.size).to eq(@works.size)
    end

    it "should create new print font" do
      @params[:new_font] = 'foo'
      post :set_print_font, @params

      expect(response).to be_success
      expect(PrintFont.last.name).to eq('foo')
    end

    it "should set works font to nil if font_id is empty" do
      @params[:font_id] = ''

      post :set_print_font, @params

      expect(response).to be_success
      expect(Work.last.wks_primary_print_font).to be_nil
    end

    it "should not save new print font if print font exists" do
      @params[:new_font] = 'foo'
      create(:print_font, pf_name: 'foo')

      post :set_print_font, @params

      expect(response).to_not be_success
    end
  end
end
