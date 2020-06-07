# frozen_string_literal: true

RSpec.describe 'Api::Articles :show', type: :request do
  let!(:article) { create(:article, published: true, published_at: Time.now) }
  let(:user) { create(:user) }
  let(:credentials) { user.create_new_auth_token }
  let(:headers) { { HTTP_ACCEPT: 'application/json' }.merge!(credentials) }
  let(:subscriber) { create(:user, role: 'subscriber') }
  let(:subscriber_credentials) { subscriber.create_new_auth_token }
  let(:subscriber_headers) { { HTTP_ACCEPT: 'application/json' }.merge!(subscriber_credentials) }
  let!(:premium_article) { create(:article, published: true, published_at: Time.now, premium: true) }

  describe 'GET /api/articles/:id' do
    before do
      get "/api/articles/#{article.id}"
    end

    it 'has a 200 response' do
      expect(response).to have_http_status 200
    end

    it 'free article is shown in full without auth' do
      expect(response_json['article']['body'].length).to eq article[:body].length
    end

    describe 'response has keys' do
      it ':title' do
        expect(response_json['article']).to have_key 'title'
      end

      it ':body' do
        expect(response_json['article']).to have_key 'body'
      end

      it ':published_at' do
        expect(response_json['article']).to have_key 'published_at'
      end

      it ':premium' do
        expect(response_json['article']).to have_key 'premium'
      end
    end
  end

  describe 'GET /api/articles/:id to non-existing id' do
    before do
      get '/api/articles/1000002'
    end

    it 'has a 404 response' do
      expect(response).to have_http_status 404
    end

    it 'responds with error message' do
      expect(response_json['message']).to eq 'Article with id 1000002 could not be found.'
    end
  end

  describe 'Vistor can see only part of a premium article' do
    before do
      get "/api/articles/#{premium_article.id}"
    end

    it 'displays premium article with a length of 300 characters only' do
      expect(response_json['article']['body'].length).to eq 300
    end
  end

  describe 'User can see only part of a premium article' do
    before do
      get "/api/articles/#{premium_article.id}", headers: headers
    end

    it 'displays premium article with a length of 300 characters only' do
      expect(response_json['article']['body'].length).to eq 300
    end
  end

  describe 'Subscriber can see full premium article' do
    before do
      get "/api/articles/#{premium_article.id}", headers: subscriber_headers
    end

    it 'displays premium article in full' do
      expect(response_json['article']['body'].length).to eq premium_article[:body].length
    end
  end
end
