ActiveAdmin.register BatchJob do

  ## Disable new and create
  actions :all, except: [:new, :create]

  ## Permit attributes to be updated
  permit_params :job_type_id, :ocr_engine_id, :parameters, :name, :notes,
                :font_id, :language_model_id, :glyph_substitution_model_id, :font_training_result_batch_job_id

  ## Member Actions - this setups the controller action for a single resource
  member_action :clone_as_ocr_batch_job, method: :put do
    ocr_batch_job = resource.clone_as_ocr_batch_job!
    redirect_to admin_batch_job_path(ocr_batch_job), notice: "Created OCR BatchJob"
  end

  ## Action Items - show page
  action_item :clone_as_ocr_batch_job, only: :show do
    if batch_job.font_training?
      link_to "Clone as OCR BatchJob", clone_as_ocr_batch_job_admin_batch_job_path(batch_job), method: :put
    end
  end

  ## Controller customizations
  controller do
    skip_before_filter :get_dropdown_data
  end

  ## Index search filters
  filter :id
  filter :name
  filter :job_type
  filter :ocr_engine
  filter :font
  filter :language_model
  filter :glyph_substitution_model
  filter :font_training_result_batch_job

  ## INDEX
  index do
    selectable_column
    id_column
    column :name
    column :job_type
    column :ocr_engine
    column :font
    column :language_model
    column :glyph_substitution_model
    column :font_training_result_batch_job
    actions
  end

  ## SHOW
  show do
    attributes_table do
      row :id
      row :name
      row :job_type
      row :ocr_engine
      row :font
      row :font_training_result_batch_job
      row :language_model
      row :glyph_substitution_model
      row :parameters
      row :notes
    end

    panel "Job Queues" do
      job_queues = JobQueue.where(batch_id: batch_job.id)
      paginated_collection(job_queues.page(params[:page]).per(15), download_links: false) do
        table_for collection do
          column :id do  |j|
            link_to j.id, admin_job_queue_path(j)
          end
          column :status
          column :proc_id
          column :job_id
          column :page_id
          column :work_id
        end
      end
    end
  end

  ## EDIT / UPDATE
  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :name
      f.input :job_type
      f.input :ocr_engine
      f.input :font
      f.input :font_training_result_batch_job
      f.input :language_model
      f.input :glyph_substitution_model
      f.input :parameters
      f.input :notes
    end
    f.actions
  end
end
