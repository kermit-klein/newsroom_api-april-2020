# frozen_string_literal: true

class Article < ApplicationRecord
  has_one_attached :image
  validates_presence_of :title, :body, :category, :location
  enum category: %i[other sport local politics economy world entertainment]
end

