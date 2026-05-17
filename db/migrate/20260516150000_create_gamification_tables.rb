class CreateGamificationTables < ActiveRecord::Migration[8.1]
  def change
    create_table :achievements, comment: "Global achievement catalog (badges)." do |t|
      t.string :slug, null: false
      t.string :name, null: false
      t.text :description, null: false
      t.integer :kind, null: false, default: 0
      t.integer :threshold, null: false, default: 1

      t.timestamps
    end

    add_index :achievements, :slug, unique: true

    create_table :user_achievements, comment: "Badge awarded to a user within a tenant." do |t|
      t.references :user, null: false, foreign_key: true
      t.references :achievement, null: false, foreign_key: true
      t.references :tenant, null: false, foreign_key: true
      t.datetime :awarded_at, null: false

      t.timestamps
    end

    add_index :user_achievements, %i[tenant_id user_id achievement_id],
              unique: true, name: "index_user_achievements_on_tenant_user_achievement"

    create_table :study_streaks, comment: "Daily study streak per student and tenant." do |t|
      t.references :user, null: false, foreign_key: true
      t.references :tenant, null: false, foreign_key: true
      t.integer :current_streak, null: false, default: 0
      t.integer :longest_streak, null: false, default: 0
      t.date :last_activity_on

      t.timestamps
    end

    add_index :study_streaks, %i[tenant_id user_id], unique: true
  end
end
