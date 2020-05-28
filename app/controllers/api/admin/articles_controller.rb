# frozen_string_literal: true

class Api::Admin::ArticlesController < ApplicationController
  before_action :authenticate_user!

  def index
    if check_authorized(:editor)
      article = Article.where(published: false)
      render json: article, each_serializer: Admin::Article::IndexSerializer
    end
  end
end

private

def render_unauthorized
  render json: { message: 'You are not authorized', errors: ['You are not authorized'] }, status: 401
end

def check_authorized(limit)
  unless User.roles[current_user.role] >= User.roles[limit]
    render_unauthorized()
    return false
  else
    return true
  end
end