# frozen_string_literal: true

class Api::ArticlesController < ApplicationController
  before_action :authenticate_user!, only: [:create]

  def index
    article = Article.where(published: true)
    render json: article, each_serializer: Article::IndexSerializer
  end

  def show
    article = Article.find(params[:id])
    raise StandardError unless article.published
    render json: article, serializer: Article::ShowSerializer
  rescue StandardError
    render json: { message: "Article with id #{params[:id]} could not be found." }, status: :not_found
  end

  def create
    article = Article.create(article_params)
    if article.persisted? && attach_image(article)
      render json: { id: article.id, message: 'Article successfully created!' }
    elsif !attach_image(article)
      render json: { message: "Image can't be blank" }, status: 400
    else
      error = "#{article.errors.first[0].to_s.capitalize} #{article.errors.first[1]}"
      render json: { message: error }, status: 400
    end
  end

  private

  def attach_image(article)
    params_image = params[:image]
    if params_image.present?
      DecodeService.attach_image(params_image, article.image)
    end
  end

  def article_params
    params.permit(:title, :body, :category)
  end
end
