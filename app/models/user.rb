# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  role                   :integer          not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  tenant_id              :bigint
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_tenant_id             (tenant_id)
#
# Foreign Keys
#
#  fk_rails_...  (tenant_id => tenants.id)
#
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, [
    :super_admin,
    :tenant_admin,
    :instructor,
    :student
  ], default: :student

  belongs_to :tenant
  has_many :enem_import_jobs, dependent: :destroy
  has_many :user_achievements, dependent: :destroy
  has_many :achievements, through: :user_achievements
  has_many :study_streaks, dependent: :destroy
  has_many :quiz_attempts, dependent: :destroy

  acts_as_tenant :tenant

  before_validation :assign_current_tenant, on: :create

  # Devise: autenticação escopada ao subdomínio (tenant) atual.
  def self.find_for_database_authentication(warden_conditions)
    tenant = ActsAsTenant.current_tenant
    return nil unless tenant

    where(tenant_id: tenant.id).find_by(email: warden_conditions[:email])
  end

  def study_streak_for(tenant = ActsAsTenant.current_tenant)
    return nil unless tenant

    study_streaks.find_by(tenant_id: tenant.id)
  end

  private

  def assign_current_tenant
    self.tenant_id ||= ActsAsTenant.current_tenant&.id
  end
end
