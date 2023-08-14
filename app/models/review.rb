class Review < ApplicationRecord
  after_save :update_book_average_rating

  belongs_to :user
  belongs_to :book

  validates :body, presence: true
  validates :rating, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 10 }

  private

  def update_book_average_rating
    book.update_average_rating
  end
end
