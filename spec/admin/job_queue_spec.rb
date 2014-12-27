require 'rails_helper'

RSpec.describe 'JobQueue' do
  let(:resource_class) { JobQueue }
  let(:all_resources)  { ActiveAdmin.application.namespaces[:admin].resources }
  let(:resource)       { all_resources[resource_class] }

  it "should be a resource" do
    expect(resource.resource_name).to eq('JobQueue')
  end

  it 'should have actions' do
    expect(resource.defined_actions).to include(:index, :show)
  end

  it 'should not have new or create actions' do
    expect(resource.defined_actions).to_not include(:new, :create, :edit, :update, :destroy)
  end

  it 'should have batch_actions' do
    expect(resource.batch_actions.map(&:sym)).to include(:mark_not_started, :mark_failed)
  end

  it 'should have batch_action destroy' do
    expect(resource.batch_actions.map(&:sym)).to_not include(:destroy)
  end

  it 'should have member_actions' do
    expect(resource.member_actions.map(&:name)).to include(:mark_not_started, :mark_failed)
  end
end
