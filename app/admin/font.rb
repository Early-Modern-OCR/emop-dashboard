ActiveAdmin.register Font do

  ## Permit these attributes to be updated
  permit_params :font_name, :font_italic, :font_bold, :font_fixed, :font_serif,
                :font_fraktur, :font_line_height, :font_library_path, :path

  ## Controller customizations
  controller do
    skip_before_filter :get_dropdown_data
  end

  ## Index search filters
  filter :font_name
  filter :path

  ## INDEX
  index do
    id_column
    column :font_name
    column :path
    actions
  end

  ## SHOW
  show do
    attributes_table do
      row :id
      row('Name') do
        font.font_name
      end
      row :font_italic
      row :font_bold
      row :font_fixed
      row :font_serif
      row :font_fraktur
      row :font_line_height
      row :font_library_path
      row :path
    end

    panel "Batch Jobs" do
      batch_jobs = font.batch_jobs
      paginated_collection(batch_jobs.page(params[:page]).per(15), download_links: false) do
        table_for collection do
          column :id do |b|
            link_to b.id, admin_batch_job_path(b)
          end
          column :name
        end
      end
    end
  end

  ## NEW / EDIT
  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :font_name, label: "Name"
      f.input :font_italic
      f.input :font_bold
      f.input :font_fixed
      f.input :font_serif
      f.input :font_fraktur
      f.input :font_line_height
      f.input :font_library_path
      f.input :path
    end
    f.actions
  end
end
