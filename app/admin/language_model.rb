ActiveAdmin.register LanguageModel do

  ## Permit these attributes to be updated
  permit_params :name, :language_id, :file

  ## Controller customizations
  controller do
    skip_before_filter :get_dropdown_data
  end

  ## Index search filters
  filter :name
  filter :language
  filter :path

  ## INDEX
  index do
    id_column
    column :name
    column :language
    column :path
    actions
  end

  ## NEW / EDIT
  form html: { multipart: true } do |f|
    f.semantic_errors
    f.inputs do
      f.input :name
      f.input :language
      f.input :file, as: :file
    end
    f.actions
  end
end
