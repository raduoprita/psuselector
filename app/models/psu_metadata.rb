class PsuMetadata < ApplicationRecord
  belongs_to :power_supply, primary_key: :model, foreign_key: :model

  validates :model, presence: true, uniqueness: true

end
