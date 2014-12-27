ActiveAdmin.register BatchJob do

  ## Disable new and create
  actions :all, except: [:new, :create]

  ## Permit attributes to be updated
  permit_params :job_type, :ocr_engine, :parameters, :name, :notes, :font

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

  ## INDEX
  index do
    selectable_column
    id_column
    column :name
    column :job_type
    column :ocr_engine
    column :font
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
      row :parameters
      row :notes
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
      f.input :parameters
      f.input :notes
    end
    f.actions
  end
end
