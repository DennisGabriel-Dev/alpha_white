class CreateCourses < ActiveRecord::Migration[8.1]
  def change
    create_table :courses do |t|
      t.references :tenant, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    # Índice composto para performance em queries tenantizadas
    add_index :courses, [:tenant_id, :id]
    add_index :courses, [:tenant_id, :name]
  end
end
