class DashboardController < ApplicationController
  
  # main dashboard summary view
  #
  def index
     wk = Work.find(151311)
     puts wk.wks_title
     wk.pages.each do |page|
        res = page.page_results.first
        puts "Page #{page.pg_ref_number}, Juxta #{res.juxta_change_index}"
     end
  end
end
