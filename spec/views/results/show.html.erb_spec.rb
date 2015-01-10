require 'rails_helper'

RSpec.describe "results/show", :type => :view do
  before(:each) do
    @print_font = create(:print_font)
    @work = create(:work, print_font: @print_font)
    @pages = create_list(:page, 2, work: @work)
    @batch_job = create(:batch_job)
    @stats = [
      'total',
      'ignored',
      'correct',
      'corrected',
      'unchanged',
    ]
    assign(:work, @work)
    assign(:batch_job, @batch_job)
    assign(:pages, @pages)
    assign(:stats, @stats)
  end

  it "sets hidden work-id" do
    render
    expect(rendered).to have_tag('span', text: @work.id, with: { id: 'work-id', style: 'display:none' })
  end

  it "sets hidden batch-id" do
    render
    expect(rendered).to have_tag('span', text: @batch_job.id, with: { id: 'batch-id', style: 'display:none' })
  end

  it "displays work title" do
    render
    expect(rendered).to have_tag('tr') do
      with_tag('td', text: 'Work:')
      with_tag('td', text: @work.wks_title)
    end
  end

  it "displays batch information" do
    render
    expect(rendered).to have_tag('tr') do
      with_tag('td', text: 'Batch:')
      with_tag('td', text: "#{@batch_job.id}: #{@batch_job.name}")
    end
  end

  it "displays print font" do
    render
    expect(rendered).to have_tag('tr') do
      with_tag('td', text: 'Print Font:')
      with_tag('td', text: @print_font.name)
    end
  end

  context "when batch_job is not present" do
    before(:each) do
      assign(:batch_job, nil)
    end

    it "sets hidden batch-id to nil" do
      render
      expect(rendered).to have_tag('span', text: nil, with: { id: 'batch-id', style: 'display:none' })
    end

    it "Sets Batch to Not Applicable" do
      render
      expect(rendered).to have_tag('tr') do
        with_tag('td', text: 'Batch:')
        with_tag('td', text: 'Not Applicable')
      end
    end
  end

  context "when work's print font is not present" do
    before(:each) do
      @work.update!(print_font: nil)
    end

    it "Sets Print Font to Not Set" do
      render
      expect(rendered).to have_tag('tr') do
        with_tag('td', text: 'Print Font:')
        with_tag('td', text: 'Not Set')
      end
    end
  end
end
