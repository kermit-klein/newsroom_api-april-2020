# frozen_string_literal: true

class Api::ArticlesController < ApplicationController
  before_action :authenticate_user!, only: [:create]

  def index
    page = params[:page] || 1
    offset = (page - 1) * 20
    case category
    when 'local'
      articles = Article
                 .where(location: params[:location])
                 .order('published_at DESC')
                 .limit(21)
                 .offset(offset)
    when 'current'
      articles = Article
                 .where(location: params[:location], published_at: Time.now - 1.day..Time.now)
                 .or(Article.where(international: true, published_at: Time.now - 1.day..Time.now))
                 .order('published_at DESC')
                 .limit(21)
                 .offset(offset)
    else
      articles = Article
                 .where(category: params[:category], location: params[:location])
                 .or(Article.where(category: params[:category], international: true))
                 .order('published_at DESC')
                 .limit(21)
                 .offset(offset)
    end
    render json: articles, each_serializer: Article::IndexSerializer
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
