require 'rails_helper'

RSpec.describe 'LanguageModel' do
  let(:resource_class) { LanguageModel }
  let(:all_resources)  { ActiveAdmin.application.namespaces[:admin].resources }
  let(:resource)       { all_resources[resource_class] }

  it "should be a resource" do
    expect(resource.resource_name).to eq('LanguageModel')
  end

  it 'should have actions' do
    expect(resource.defined_actions).to include(:new, :create, :update, :index, :show, :edit, :destroy)
  end
end
