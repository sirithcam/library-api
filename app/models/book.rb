class Book < ApplicationRecord
  has_many :reviews, dependent: :destroy

  validates :name, presence: true
  validates :author, presence: true
  validates :genre, presence: true
  validates :release_date, presence: true
  validates :rating, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 10 }

  before_validation :set_default_rating

  private

  def set_default_rating
    self.rating ||= 0
  end
end
