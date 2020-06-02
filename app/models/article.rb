# frozen_string_literal: true

class Article < ApplicationRecord
  has_one_attached :image
  validates_presence_of :title, :body, :category, :location
  enum category: %i[other sport local politics economy world entertainment]
  # validates :location, presence: { accept: 'Sweden', message: "Should have a valid location" }
  # validate :locations, on: :update

  # def locations 
  #   if location != "Sweden"
  #     errors.add(:location, "Should have a valid location")
  #     # binding.pry
  #     # errors.add(:message, "Should have a valid location")
  #   end
  # end
end

