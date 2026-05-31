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

  FEATURE_FLAGS = {
    "gamification" => true,
    "reports" => true,
    "enem_library" => true,
    "csv_export" => true
  }.freeze

  DEFAULT_TAGLINE = "Sua aprovação no ENEM começa aqui"
  DEFAULT_META_DESCRIPTION = "Prepare-se para o ENEM com cursos completos, trilhas de estudo e simulados realistas."

  validates :name, presence: true
  validates :subdomain, presence: true, uniqueness: true,
                        format: { with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/,
                                  message: "apenas letras minúsculas, números e hífens" }
  validates :theme, inclusion: { in: THEMES }

  scope :active, -> { where(active: true) }

  has_one_attached :logo
  has_one_attached :favicon

  # Associations
  has_many :courses, dependent: :destroy
  has_many :users, dependent: :destroy
  has_many :enem_import_jobs, dependent: :destroy

  def feature_enabled?(key)
    key = key.to_s
    return false unless FEATURE_FLAGS.key?(key)

    raw = (feature_flags || {})[key]
    return FEATURE_FLAGS[key] if raw.nil?

    ActiveModel::Type::Boolean.new.cast(raw)
  end

  def assign_feature_flags_from_params(raw, form: false)
    return if raw.nil?

    self.feature_flags = FEATURE_FLAGS.keys.index_with do |flag_key|
      if raw.key?(flag_key)
        ActiveModel::Type::Boolean.new.cast(raw[flag_key])
      elsif form
        false
      else
        feature_enabled?(flag_key)
      end
    end
  end
end
