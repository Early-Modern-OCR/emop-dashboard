require 'rails_helper'

RSpec.describe 'Language' do
  let(:resource_class) { Language }
  let(:all_resources)  { ActiveAdmin.application.namespaces[:admin].resources }
  let(:resource)       { all_resources[resource_class] }

  it "should be a resource" do
    expect(resource.resource_name).to eq('Language')
  end

  it 'should have actions' do
    expect(resource.defined_actions).to include(:new, :create, :update, :index, :show, :edit, :destroy)
  end
end
