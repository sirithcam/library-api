class User < ApplicationRecord
  # Devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Custom fields
  validates :firstname, :lastname, presence: true
  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, confirmation: true
end
