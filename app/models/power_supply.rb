class PowerSupply < ApplicationRecord
  has_one :psu_price, primary_key: :model, foreign_key: :model

  after_create :find_or_create_psu_price
  after_save :update_psu_price

  validates :model, presence: true, uniqueness: true
  validates :manufacturer, presence: true
  validates :atx_version, presence: true
  validates :wattage, presence: true, numericality: true
  validates :efficiency_rating, presence: true

  def self.rebuild_prices
    PowerSupply.all.each do |ps|
      ps.update(price: ps.p_price)
    end
  end

  def p_price
    psu_price&.price
  end


  private

  def find_or_create_psu_price
    PsuPrice.find_or_create_by(model: model)
  end

  def update_psu_price
    self.reload.psu_price.update(price: price) if price
  end
end
