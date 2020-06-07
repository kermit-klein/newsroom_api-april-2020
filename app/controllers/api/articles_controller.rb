# frozen_string_literal: true

class Api::ArticlesController < ApplicationController
  before_action :authenticate_user!, only: [:create]

  def index
    check_index_params
    category = params[:category] || 'all'

    case category
    when 'local'
      articles = find_articles({}, { id: -1 })
    when 'current'
      last_24hrs = Time.now - 1.day..Time.now
      articles = find_articles({ published_at: last_24hrs })
    when 'all'
      articles = find_articles({})
    else
      articles = find_articles({ category: category })
    end

    render json: create_json_response(articles)
  rescue StandardError => e
    render json: { message: e.message }, status: 422
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

  def check_index_params
    valid_categories = Article.categories.keys + %w[current local]
    if params[:location] && !params[:location].is_a?(String)
      raise TypeError, 'Location parameter must be a string'
    elsif params[:page] && params[:page].to_i < 1
      raise TypeError, 'Page parameter must be a positive integer'
    elsif params[:category] && !valid_categories.include?(params[:category])
      raise TypeError, "Category parameter must be omitted or one of the following: #{valid_categories.join(", ")}"
    end
  end

  def find_articles(main_params, opt_params = {})
    page = params[:page] || 1
    @page = page.to_i
    offset = (@page - 1) * 24

    Article
      .where(**main_params, location: params[:location], published: true)
      .or(Article.where(**main_params, **opt_params, international: true, published: true))
      .order('published_at DESC')
      .limit(25)
      .offset(offset)
  end

  def create_json_response(articles)
    next_page = articles.length > 24 ? @page + 1 : nil
    json = { articles: articles[0...24].map { |article| Article::IndexSerializer.new(article) } }
    json.merge!(page: @page, next_page: next_page)
  end

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
