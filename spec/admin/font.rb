require 'rails_helper'

RSpec.describe 'Font' do
  let(:resource_class) { Font }
  let(:all_resources)  { ActiveAdmin.application.namespaces[:admin].resources }
  let(:resource)       { all_resources[resource_class] }

  it "should be a resource" do
    expect(resource.resource_name).to eq('Font')
  end

  it 'should have actions' do
    expect(resource.defined_actions).to include(:new, :create, :update, :index, :show, :edit, :destroy)
  end
end
