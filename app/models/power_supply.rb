class PowerSupply < ApplicationRecord
  has_one :psu_metadata, primary_key: :model, foreign_key: :model

  after_create :find_or_create_metadata
  after_save :update_metadata

  validates :model, presence: true, uniqueness: true
  validates :manufacturer, presence: true
  validates :atx_version, presence: true
  validates :wattage, presence: true, numericality: true
  validates :efficiency_rating, presence: true

  def metadata_price
    psu_metadata&.price
  end

  def favorite?
    psu_metadata&.favorite
  end

  def favorite=(value)
    psu_metadata&.update(favorite: value)
  end

  private

  def find_or_create_metadata
    PsuMetadata.find_or_create_by(model: model)
    self.update(price: metadata_price)
  end

  def update_metadata
    self.reload.psu_metadata.update(price: price) if price
  end
end
