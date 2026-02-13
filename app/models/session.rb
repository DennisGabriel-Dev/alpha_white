# == Schema Information
#
# Table name: sessions(Sessions of a course. Each session belongs to a course and tenant.)
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  position   :integer          default(0), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  course_id  :bigint           not null
#  tenant_id  :bigint           not null
#
# Indexes
#
#  index_sessions_on_course_id               (course_id)
#  index_sessions_on_course_id_and_position  (course_id,position)
#  index_sessions_on_tenant_id               (tenant_id)
#  index_sessions_on_tenant_id_and_id        (tenant_id,id)
#
# Foreign Keys
#
#  fk_rails_...  (course_id => courses.id)
#  fk_rails_...  (tenant_id => tenants.id)
#
class Session < ApplicationRecord
  acts_as_tenant :tenant

  belongs_to :course
  belongs_to :tenant

  before_validation :set_tenant_from_course, on: :create

  validates :name, presence: true

  private

  def set_tenant_from_course
    self.tenant_id ||= course&.tenant_id
  end

  default_scope { order(position: :asc, id: :asc) }
end
