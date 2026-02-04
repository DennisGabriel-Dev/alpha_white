class AddTenantConstraints < ActiveRecord::Migration[8.1]
  def change
    # Add constraint to ensure subdomain is lowercase
    reversible do |dir|
      dir.up do
        execute <<-SQL
          ALTER TABLE tenants
          ADD CONSTRAINT subdomain_lowercase
          CHECK (subdomain = LOWER(subdomain));
        SQL
      end

      dir.down do
        execute "ALTER TABLE tenants DROP CONSTRAINT subdomain_lowercase;"
      end
    end

    # Add comments to tables for documentation
    change_table_comment :tenants, "Table tenants (schools). Each tenant represents a whitelabel school."
    change_table_comment :courses, "Table courses. Each course belongs to a specific tenant."

    # Add comments to important columns
    change_column_comment :tenants, :subdomain, "Unique subdomain for the tenant (ex: 'objetivo' for objetivo.seudominio.com)"
    change_column_comment :courses, :tenant_id, "Reference to the tenant (school) owner of this course"
  end
end
