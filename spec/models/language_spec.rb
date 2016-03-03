require 'rails_helper'

RSpec.describe Language, :type => :model do
  let(:language) { create(:language) }

  it "is valid" do
    expect(language).to be_valid
  end

  describe 'ActiveModel validations' do
    it { expect(language).to validate_presence_of(:name) }
    it { expect(language).to validate_uniqueness_of(:name) }
  end
end
