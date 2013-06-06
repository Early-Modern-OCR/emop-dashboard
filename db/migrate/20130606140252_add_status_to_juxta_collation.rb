class AddStatusToJuxtaCollation < ActiveRecord::Migration
  def change
     add_column :juxta_collations, :status, "ENUM('created', 'ready', 'error')", :default => :created
  end
end
