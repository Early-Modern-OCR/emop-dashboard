ActiveAdmin.register GlyphSubstitutionModel do

  ## Permit these attributes to be updated
  permit_params :name, :file

  ## Controller customizations
  controller do
    skip_before_filter :get_dropdown_data
  end

  ## Index search filters
  filter :name
  filter :path

  ## INDEX
  index do
    id_column
    column :name
    column :path
    actions
  end

  ## NEW / EDIT
  form html: { multipart: true } do |f|
    f.semantic_errors
    f.inputs do
      f.input :name
      f.input :file, as: :file
    end
    f.actions
  end
end
