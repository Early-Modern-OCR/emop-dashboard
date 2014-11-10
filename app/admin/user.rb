ActiveAdmin.register User do

  permit_params :email, :password, :password_confirmation

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

  filter :email

  index do
    id_column
    column :email
    column :created_at
    column :current_sign_in_at
    column :last_sign_in_at
    actions
  end

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
