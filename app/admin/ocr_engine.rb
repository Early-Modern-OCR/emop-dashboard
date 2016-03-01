ActiveAdmin.register OcrEngine do

  menu label: "OCR Engines"

  ## Permit these attributes to be updated
  permit_params :name

  ## Controller customizations
  controller do
    skip_before_filter :get_dropdown_data
  end

  ## Index search filters
  filter :name

  ## INDEX
  index do
    id_column
    column :name
    actions
  end

  ## SHOW
  show do
    attributes_table do
      row :id
      row :name
    end
  end

  ## NEW / EDIT
  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :name
    end
    f.actions
  end
end
