require 'rails_helper'

RSpec.describe WorksCollection, :type => :model do
  let(:works_collection) { create(:works_collection) }

  it "is valid" do
    expect(works_collection).to be_valid
  end

  describe 'ActiveModel validations' do
    it { expect(works_collection).to validate_presence_of(:name) }
    it { expect(works_collection).to validate_uniqueness_of(:name) }
  end
end
