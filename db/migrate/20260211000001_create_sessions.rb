class CreateSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :sessions, comment: "Sessions of a course. Each session belongs to a course and tenant." do |t|
      t.references :course, null: false, foreign_key: true
      t.references :tenant, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :position, default: 0, null: false

      t.timestamps
    end

    add_index :sessions, [ :tenant_id, :id ]
    add_index :sessions, [ :course_id, :position ]
  end
end
