# frozen_string_literal: true

class Article::ShowSerializer < ActiveModel::Serializer

  attributes :id, :title, :body, :published_at, :premium, :image
  
  def published_at
    object.created_at.strftime('%F %R')
  end

  def body
    object.premium && current_user.nil? ? object.body[0..99] : object.body
  end
end
