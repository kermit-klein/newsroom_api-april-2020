# frozen_string_literal: true

class Api::Admin::ArticlesController < ApplicationController
  before_action :authenticate_user!

  def index
    if current_user.role >= 'editor'
      article = Article.where(published: false)
      render json: article, each_serializer: Admin::Article::IndexSerializer
    else
      render_unauthorized
    end
  end
end
