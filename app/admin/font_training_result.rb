ActiveAdmin.register FontTrainingResult do

  ## Disable new and create
  actions :all, except: [:new, :create, :destroy, :edit, :update]

  config.batch_actions = false

  ## Controller customizations
  controller do
    skip_before_filter :get_dropdown_data
  end

  ## Index search filters
  filter :id
  filter :batch_job
  filter :work
  filter :font_path
  filter :language_model_path
  filter :glyph_substitution_model_path

  ## INDEX
  index do
    selectable_column
    id_column
    column :name
    column :batch_job
    column :work
    actions
  end

  ## SHOW
  show do
    attributes_table do
      row :id
      row :batch_job
      row :work
      row :font_path
      row :language_model_path
      row :glyph_substitution_model_path
    end
  end
end
