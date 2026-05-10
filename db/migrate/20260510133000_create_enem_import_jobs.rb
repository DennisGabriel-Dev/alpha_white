class CreateEnemImportJobs < ActiveRecord::Migration[8.1]
  def change
    create_table :enem_import_jobs, comment: "Tenant-scoped import jobs for ENEM PDF pairs." do |t|
      t.references :user, null: false, foreign_key: true
      t.references :tenant, null: false, foreign_key: true
      t.references :enem_exam, null: true, foreign_key: true
      t.integer :status, null: false, default: 0
      t.text :error_message

      t.timestamps
    end

    add_index :enem_import_jobs, %i[tenant_id status created_at]
    add_index :enem_import_jobs, %i[tenant_id id]
  end
end
