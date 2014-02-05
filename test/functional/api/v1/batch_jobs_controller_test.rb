require 'test_helper'

module Api
  module V1
    class BatchJobsControllerTest < ActionController::TestCase
      setup do
        @batch_job = batch_jobs(:one)
      end

      test "should get index" do
        get :index
        assert_response :success
        assert_not_nil assigns(:batch_jobs)
      end
    end
  end
end
