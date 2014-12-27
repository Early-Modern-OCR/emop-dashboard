require 'rails_helper'

RSpec.describe 'Work' do
  let(:resource_class) { Work }
  let(:all_resources)  { ActiveAdmin.application.namespaces[:admin].resources }
  let(:resource)       { all_resources[resource_class] }

  it "should be a resource" do
    expect(resource.resource_name).to eq('Work')
  end

  it 'should have actions' do
    expect(resource.defined_actions).to include(:update, :index, :show, :edit)
  end

  it 'should not have new or create actions' do
    expect(resource.defined_actions).to_not include(:new, :create, :destroy)
  end
end
