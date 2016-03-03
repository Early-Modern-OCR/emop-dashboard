require 'rails_helper'

RSpec.describe "dashboard/index", :type => :view do

  it "renders a dashboard" do
    assign(:fonts, [create(:font)])
    assign(:print_fonts, [create(:print_font)])
    assign(:batches, [create(:batch_job)])
    assign(:queue_status, JobQueue.status_summary)
    assign(:q, Work.ransack())
    render
  end

end
