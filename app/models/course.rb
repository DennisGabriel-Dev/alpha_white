# == Schema Information
#
# Table name: courses(Table courses. Each course belongs to a specific tenant.)
#
#  id                                                               :bigint           not null, primary key
#  active                                                           :boolean          default(TRUE), not null
#  description                                                      :text
#  name                                                             :string           not null
#  created_at                                                       :datetime         not null
#  updated_at                                                       :datetime         not null
#  tenant_id(Reference to the tenant (school) owner of this course) :bigint           not null
#
# Indexes
#
#  index_courses_on_tenant_id           (tenant_id)
#  index_courses_on_tenant_id_and_id    (tenant_id,id)
#  index_courses_on_tenant_id_and_name  (tenant_id,name)
#
# Foreign Keys
#
#  fk_rails_...  (tenant_id => tenants.id)
#
class Course < ApplicationRecord
  acts_as_tenant :tenant

  belongs_to :tenant

  validates :name, presence: true
  validates :description, length: { maximum: 1000 }

  scope :active, -> { where(active: true) }
end
