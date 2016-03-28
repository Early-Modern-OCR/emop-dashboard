require 'rails_helper'

RSpec.describe 'FontTrainingResult' do
  let(:resource_class) { FontTrainingResult }
  let(:all_resources)  { ActiveAdmin.application.namespaces[:admin].resources }
  let(:resource)       { all_resources[resource_class] }

  it "should be a resource" do
    expect(resource.resource_name).to eq('FontTrainingResult')
  end

  it 'should have actions' do
    expect(resource.defined_actions).to include(:index, :show)
  end

  it 'should not have new or create actions' do
    expect(resource.defined_actions).to_not include(:new, :create, :update, :edit, :destroy)
  end

  it 'should not have batch_actions' do
    expect(resource.batch_actions.map(&:sym)).to_not include(:destroy)
  end
end
