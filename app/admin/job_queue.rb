ActiveAdmin.register JobQueue do

  ## Disable new, create, edit, update and destroy
  actions :all, except: [:new, :create, :edit, :update, :destroy]

  ## Permit these attributes to be updated - unneeded since actions are disabled
  #permit_params :status, :proc_id

  ## Batch Actions
  batch_action :destroy, false #TODO: Reevaluate if we want this disabled
  batch_action :mark_not_started, confirm: "Are you sure you want to mark Not Started?" do |ids|
    JobQueue.where(id: ids).reschedule!

    redirect_to collection_path, alert: "The job queues have been marked Not Started."
  end
  
  batch_action :mark_failed, confirm: "Are you sure you want to mark Failed?" do |ids|
    JobQueue.find(ids).each do |job_queue|
      job_queue.mark_failed!
    end

    redirect_to collection_path, alert: "The job queues have been marked Failed."
  end

  ## Collection Actions - these setup controller and routes for action on a collection
  collection_action :reschedule, method: :post do
    filter = params[:q]
    query = JobQueue.ransack(filter)
    job_queues = query.result(distinct: true)
    count = job_queues.reschedule!
    redirect_to collection_path, notice: "#{count} jobs rescheduled!"
  end

  ## Member Actions - this setups the controller action for a single resource
  member_action :mark_not_started, method: :put do
    resource.mark_not_started!
    redirect_to resource_path, notice: "Marked Not Started!"
  end

  member_action :mark_failed, method: :put do
    resource.mark_failed!
    redirect_to resource_path, notice: "Marked Failed!"
  end

  ## Action Items - index page
  action_item :reschedule, only: :index do
    link_to "Reschedule All", reschedule_admin_job_queues_path(q: params[:q]),
      method: :post, confirm: 'Are you sure?'
  end

  ## Action Items - show page
  action_item :mark_not_started, only: :show do
    link_to "Mark Not Started", mark_not_started_admin_job_queue_path(job_queue), method: :put
  end

  action_item :mark_failed, only: :show do
    link_to "Mark Failed", mark_failed_admin_job_queue_path(job_queue), method: :put
  end

  ## Controller customizations
  controller do
    skip_before_filter :get_dropdown_data
  end

  ## Index search filters
  filter :id
  filter :status
  filter :results
  filter :proc_id
  filter :job_id
  filter :batch_job

  ## INDEX
  index do
    selectable_column
    id_column
    column :status
    column :proc_id
    column :job_id
    actions do |job_queue|
      # Must concatinate the links for both to show up.  May change as ActiveAdmin improves
      link_to("Mark Not Started", mark_not_started_admin_job_queue_path(job_queue), class: "member_link", method: :put) +
      link_to("Mark Failed", mark_failed_admin_job_queue_path(job_queue), class: "member_link", method: :put)
   end
  end

  ## SHOW
  show do
    attributes_table do
      row :id
      row :status do
        job_queue.status.name
      end
      row :proc_id
      row :job_id
      row :tries
      row :results
      row :batch_job do
        link_to "#{job_queue.batch_job.id}: #{job_queue.batch_job.name}", admin_batch_job_path(job_queue.batch_job)
      end
      row :page do
        job_queue.page.id
      end
      row :work do
        link_to "Work ##{job_queue.work.id}", admin_work_path(job_queue.work)
      end
      row :created
      row :last_update
    end
  end
end
