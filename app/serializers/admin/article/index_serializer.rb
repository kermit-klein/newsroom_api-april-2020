# frozen_string_literal: true

class Admin::Article::IndexSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers
  attributes :id, :title, :category, :created_at

  def created_at
    object.created_at.strftime('%F %R')
  end
end
