class Review < ApplicationRecord
  belongs_to :user
  belongs_to :book

  validates :body, presence: true
  validates :rating, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 10 }
end
