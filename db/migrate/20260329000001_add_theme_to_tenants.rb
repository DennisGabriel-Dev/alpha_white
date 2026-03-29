class AddThemeToTenants < ActiveRecord::Migration[8.1]
  def change
    add_column :tenants, :theme, :string, null: false, default: "default"
  end
end
