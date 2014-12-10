require 'rails_helper'

RSpec.describe Admin::WorksController, :type => :controller do
  login_user

  it 'should have a current_user' do
    expect(subject.current_user).to eq(User.first)
  end

  it 'should have index view' do
    get :index

    expect(response).to be_success
  end
end
