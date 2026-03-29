# == Schema Information
#
# Table name: tenants(Table tenants (schools). Each tenant represents a whitelabel school.)
#
#  id                                                                                      :bigint           not null, primary key
#  active                                                                                  :boolean          default(TRUE), not null
#  logo_url                                                                                :string
#  name                                                                                    :string           not null
#  primary_color                                                                           :string           default("#3C0094")
#  subdomain(Unique subdomain for the tenant (ex: 'objetivo' for objetivo.seudominio.com)) :string           not null
#  created_at                                                                              :datetime         not null
#  updated_at                                                                              :datetime         not null
#
# Indexes
#
#  index_tenants_on_subdomain  (subdomain) UNIQUE
#
class Tenant < ApplicationRecord
  THEMES = %w[default aurora merma].freeze

  validates :name, presence: true
  validates :subdomain, presence: true, uniqueness: true,
                        format: { with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/,
                                  message: "apenas letras minúsculas, números e hífens" }
  validates :theme, inclusion: { in: THEMES }

  scope :active, -> { where(active: true) }

  # Associations
  has_many :courses, dependent: :destroy
  has_many :users, dependent: :destroy
end
