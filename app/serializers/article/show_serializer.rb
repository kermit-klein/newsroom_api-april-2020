# frozen_string_literal: true

class Article::ShowSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers
  attributes :id, :title, :body, :published_at, :premium, :image

  def published_at
    object.published_at.strftime('%F %R')
  end

  def body
    object.premium && (current_user.nil? || current_user.role == 'user') ? object.body[0..299] : object.body
  end

  def image
    return nil unless object.image.attached?

    if Rails.env.test?
      rails_blob_url(object.image)
    else
      object.image.service_url(expires_in: 1.hour, disposition: 'inline')
    end
  end
end
