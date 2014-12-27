ActiveAdmin.register User do

  ## Permit these attributes to be updated
  permit_params :email, :password, :password_confirmation

  ## Controller customizations
  controller do
    skip_before_filter :get_dropdown_data

    def update
      if params[:user][:password].blank?
        params[:user].delete("password")
        params[:user].delete("password_confirmation")
      end

      super
    end
  end

  ## Index search filters
  filter :email

  ## INDEX
  index do
    id_column
    column :email
    column :created_at
    column :current_sign_in_at
    column :last_sign_in_at
    actions
  end

  ## NEW / EDIT
  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :email
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end
end
