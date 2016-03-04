require 'rails_helper'

RSpec.describe LanguageModel, :type => :model do
  let(:language_model) { create(:language_model) }

  it "is valid" do
    expect(language_model).to be_valid
  end

  describe 'ActiveModel validations' do
    it { expect(language_model).to validate_presence_of(:name) }
    it { expect(language_model).to validate_presence_of(:language) }
    it { expect(language_model).to validate_uniqueness_of(:name) }
    it { expect(language_model).to validate_uniqueness_of(:path) }
  end

  describe 'file' do
    it 'should be path' do
      expect(language_model.file).to eq(language_model.path)
    end
  end

  describe 'file=' do
    before(:each) do
      extend ActionDispatch::TestProcess
      @file = fixture_file_upload('files/spanish_2-29.lmser', 'application/octet-stream')
      class << @file
        # The reader method is present in a real invocation,
        # but missing from the fixture object for some reason.
        attr_reader :tempfile
      end
      # Mock the emop_font_dir path
      @language_model_dir = Dir.mktmpdir
      allow(Settings).to receive(:language_model_path) { @language_model_dir }
      @expected_path = File.join(@language_model_dir, 'spanish_2-29.lmser')
    end

    it 'should set path' do
      language_model.file = @file
      expect(language_model.path).to eq(@expected_path)
    end

    it 'should save file' do
      language_model.file = @file
      expect(File.exists?(@expected_path)).to be true
    end
  end
end
