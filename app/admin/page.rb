ActiveAdmin.register Page do

  ## Disable new, create, edit, update and destroy
  actions :all, except: [:new, :create, :edit, :update, :destroy]

  ## Permit these attributes to be updated
  permit_params :pg_ref_number, :pg_ground_truth_file, :pg_work_id, :pg_gale_ocr_file, :pg_image_path

  ## Controller customizations
  controller do
    skip_before_filter :get_dropdown_data
  end

  ## Index search filters
  filter :pg_work_id, label: 'Work ID'
  filter :pg_ref_number
  filter :pg_ground_truth_file
  filter :pg_gale_ocr_file
  filter :pg_image_path

  ## INDEX
  index do
    id_column
    column :work
    column :pg_ref_number
    actions
  end

  ## SHOW
  show do
    attributes_table do
      row :id
      row :work do
        link_to "Work ##{page.work.id}", admin_work_path(page.work)
      end
      row :pg_ref_number
      row :pg_ground_truth_file
      row :pg_gale_ocr_file
      row :pg_image_path
    end

    panel "JobQueues" do
      job_queues = page.job_queues
      paginated_collection(job_queues.page(params[:page]).per(15), download_links: false) do
        table_for collection do
          column :id do |j|
            link_to j.id, admin_job_queue_path(j)
          end
          column :batch_id
          column :status do |j|
            j.status.name
          end
        end
      end
    end

  end
end
