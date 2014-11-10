require 'rails_helper'

RSpec.describe User, :type => :model do
  it "is valid" do
    user = build(:user)
    expect(user).to be_valid
  end

  it "generates auth_token" do
    user = build(:user)
    user.save!
    expect(user.auth_token).not_to be_nil
  end
end
