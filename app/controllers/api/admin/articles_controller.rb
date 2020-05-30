# frozen_string_literal: true

class Api::Admin::ArticlesController < ApplicationController
  before_action :authenticate_user!
  before_action :editor?

  def index
    article = Article.where(published: false)
    render json: article, each_serializer: Admin::Article::IndexSerializer
  end

  def show
    article = Article.find(params[:id])
    if article.published == true
      render json: { message: 'This article was already published' }, status: 400
    else
      render json: article, serializer: Admin::Article::ShowSerializer
    end
  rescue StandardError
    render json: { message: "Article with id #{params[:id]} could not be found." }, status: 404
  end

  private

  def editor?
    unless current_user.role == 'editor'
      render json: { message: 'You are not authorized', errors: ['You are not authorized'] }, status: 401
    end
  end
end
