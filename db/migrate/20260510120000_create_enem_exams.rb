class CreateEnemExams < ActiveRecord::Migration[8.1]
  def change
    create_table :enem_exams, comment: "Canonical ENEM exam edition (global, no tenant)." do |t|
      t.integer :year, null: false
      t.string :day, null: false, comment: "D1 or D2"
      t.string :booklet_color, null: false
      t.jsonb :metadata, null: false, default: {}

      t.timestamps
    end

    add_index :enem_exams, %i[year day booklet_color], unique: true, name: "index_enem_exams_on_year_day_booklet"
  end
end
