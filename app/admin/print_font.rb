ActiveAdmin.register PrintFont do

  ## Permit these attributes to be updated
  permit_params :pf_name

  ## Controller customizations
  controller do
    skip_before_filter :get_dropdown_data
  end

  ## Index search filters
  filter :pf_name

  ## INDEX
  index do
    id_column
    column :pf_name
    actions
  end

  ## SHOW
  show do
    attributes_table do
      row :id
      row('Name') do
        print_font.pf_name
      end
    end

    panel "Works" do
      works = print_font.works
      paginated_collection(works.page(params[:page]).per(15), download_links: false) do
        table_for collection do
          column :id do |w|
            link_to w.id, admin_work_path(w)
          end
          column :wks_title
        end
      end
    end
  end

  ## NEW / EDIT
  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :pf_name, label: "Name"
    end
    f.actions
  end
end
