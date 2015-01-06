require 'rails_helper'

RSpec.describe PostprocPage, :type => :model do
  let(:postproc_page) { build(:postproc_page) }

  it "is valid" do
    expect(postproc_page).to be_valid
  end

  it 'should have unique page and batch_job' do
    attributes = {
      page: create(:page),
      batch_job: create(:batch_job),
    }

    @postproc_page = PostprocPage.create!(attributes)
    expect(@postproc_page).to be_valid

    @postproc_page = PostprocPage.new(attributes)
    expect(@postproc_page).not_to be_valid
    expect(@postproc_page.errors[:page]).to include("has already been taken")
  end

  describe "to_builder" do
    it "has valid to_builder - v1" do
      json = postproc_page.to_builder('v1').attributes!
      expect(json).to match(
        'pp_noisemsr'   => postproc_page.pp_noisemsr,
        'pp_ecorr'      => postproc_page.pp_ecorr,
        'pp_juxta'      => postproc_page.pp_juxta,
        'pp_retas'      => postproc_page.pp_retas,
        'pp_health'     => postproc_page.pp_health,
        'pp_pg_quality' => postproc_page.pp_pg_quality,
        'noisiness_idx' => postproc_page.noisiness_idx,
        'multicol'      => postproc_page.multicol,
        'skew_idx'      => postproc_page.skew_idx,
        'page'          => include(postproc_page.page.to_builder.attributes!),
        'batch_job'     => include(postproc_page.batch_job.to_builder.attributes!),
      )
    end
  end
end
