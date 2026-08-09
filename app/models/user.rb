class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :messages, dependent: :destroy

  normalizes :email, with: ->(e) { e.strip.downcase }
end
