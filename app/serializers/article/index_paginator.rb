# frozen_string_literal: true

class Article::IndexPaginator < ActiveModel::Serializer
  include Rails.application.routes.url_helpers
  attributes :page, :next_page, articles:

  def page
    binding.pry
    object.page
  end

  def next_page
    object.articles.length > 20 ? object.page + 1 : nil
  end

  def articles
    object.articles.each do |article|
      Articles::IndexSerializer.new(article)
    end
  end
end
