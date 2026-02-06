class AddBrandingToTenants < ActiveRecord::Migration[8.1]
  def change
    add_column :tenants, :primary_color, :string, default: '#3C0094'
    add_column :tenants, :logo_url, :string
  end
end
