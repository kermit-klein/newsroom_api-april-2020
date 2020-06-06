# frozen_string_literal: true

class Article < ApplicationRecord
  has_one_attached :image
  validates_presence_of :title, :body, :category
  enum category: %i[other sport politics economy world entertainment]
end

