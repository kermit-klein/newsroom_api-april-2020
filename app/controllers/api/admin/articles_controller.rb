class Api::Admin::ArticlesController < ApplicationController
  before_action :authenticate_user!, only: [:create]

  def index
    article = Article.where(published: false)
    render json: article, each_serializer: Admin::Article::IndexSerializer
  end
end
