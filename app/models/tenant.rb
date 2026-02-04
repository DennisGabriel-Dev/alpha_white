class Tenant < ApplicationRecord
  validates :name, presence: true
  validates :subdomain, presence: true, uniqueness: true,
                        format: { with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/,
                                  message: "apenas letras minúsculas, números e hífens" }

  scope :active, -> { where(active: true) }
end
