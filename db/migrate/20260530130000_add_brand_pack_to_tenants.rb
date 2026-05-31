class AddBrandPackToTenants < ActiveRecord::Migration[8.1]
  def change
    add_column :tenants, :tagline, :string
    add_column :tenants, :meta_description, :string
    add_column :tenants, :feature_flags, :jsonb, default: {}, null: false
  end
end
