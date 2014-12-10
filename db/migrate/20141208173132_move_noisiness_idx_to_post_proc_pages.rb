class MoveNoisinessIdxToPostProcPages < ActiveRecord::Migration
  def change
    PageResult.where.not(noisiness_idx: nil) do |page_result|
      @postproc_page = PostprocPage.find_or_create_by(page_id: page_result.page_id, batch_job_id: page_result.batch_id)
      @postproc_page.noisiness_idx = page_result.noisiness_idx
      @postproc_page.save!
    end
  end
end
