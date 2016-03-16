require 'rails_helper'

RSpec.describe GlyphSubstitutionModel, :type => :model do
  let(:glyph_substitution_model) { create(:glyph_substitution_model) }

  it "is valid" do
    expect(glyph_substitution_model).to be_valid
  end

  describe 'ActiveModel validations' do
    it { expect(glyph_substitution_model).to validate_presence_of(:name) }
    it { expect(glyph_substitution_model).to validate_uniqueness_of(:name) }
    it { expect(glyph_substitution_model).to validate_uniqueness_of(:path) }
  end

  describe 'file' do
    it 'should be path' do
      expect(glyph_substitution_model.file).to eq(glyph_substitution_model.path)
    end
  end

  describe 'file=' do
    before(:each) do
      extend ActionDispatch::TestProcess
      @file = fixture_file_upload('files/uniform.gsmser', 'application/octet-stream')
      class << @file
        # The reader method is present in a real invocation,
        # but missing from the fixture object for some reason.
        attr_reader :tempfile
      end
      # Mock the gsm_path path
      @glyph_substitution_model_dir = Dir.mktmpdir
      allow(Settings).to receive(:gsm_path) { @glyph_substitution_model_dir }
      @expected_path = File.join(@glyph_substitution_model_dir, 'uniform.gsmser')
    end

    it 'should set path' do
      glyph_substitution_model.file = @file
      expect(glyph_substitution_model.path).to eq(@expected_path)
    end

    it 'should save file' do
      glyph_substitution_model.file = @file
      expect(File.exists?(@expected_path)).to be true
    end
  end
end
