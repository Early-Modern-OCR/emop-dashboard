require 'rails_helper'

RSpec.describe PrintFont, :type => :model do
  let(:print_font) { create(:print_font) }

  it "is valid" do
    expect(print_font).to be_valid
  end

  describe "to_builder" do
    it "has valid to_builder - v1" do
      json = print_font.to_builder('v1').attributes!

      expect(json).to match(
        'id'    => print_font.id,
        'name'  => print_font.name,
      )
    end
  end
end
