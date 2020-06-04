# frozen_string_literal: true

RSpec.describe 'Api::Articles :index', type: :request do
  categories = Article.categories.keys
  categories.each do |category|
    let!("#{category}_articles".to_sym) { 4.times { create(:article, category: category) } }
  end
  let!(:extra_swedish_sport_articles) { 9.times { create(:article, location: "Sweden", international: false )}}
  let!(:extra_swedish_international_sport_articles) { 9.times { create(:article, location: "Sweden", international: true )}}
  let!(:extra_international_sport_articles) { 9.times { create(:article, location: nil, international: true )}}
  let!(:unpublished_articles) { 3.times { create(:article, published: false) } }
  
  describe 'GET /api/articles without any params' do
    before do
      get '/api/articles'
    end
    
    it 'has a 200 response' do
      expect(response).to have_http_status 200
    end

    it 'returns first page of articles' do
      expect(response_json['page']).to eq 1
    end

    it 'returns index of next page' do
      expect(response_json['next_page']).to eq 2
    end

    it 'returns one batch of 20 of the latest international articles' do
      expect(response_json['articles'].length).to eq 20
    end

    it 'returns only published articles' do
      response_json['articles'].each do |article|
        expect(article['published_at']).not_to eq nil
      end
    end

    describe 'response has keys' do
      it ':title' do
        expect(response_json['articles'][0]).to have_key 'title'
      end

      it ':category' do
        expect(response_json['articles'][0]).to have_key 'category'
      end

      it ':published_at' do
        expect(response_json['articles'][0]).to have_key 'published_at'
      end

      it ':location' do
        expect(response_json['articles'][0]).to have_key 'location'
      end

      it ':international' do
        expect(response_json['articles'][0]).to have_key 'international'
      end
    end
  end

  describe 'GET /api/articles with params...' do
    it 'location, ' do
      get '/api/articles',
        params: { location: "Sweden" }
      
      expect(response_json)
    end
    
    it 'has a 200 response' do
      expect(response).to have_http_status 200
    end
  end

  describe 'GET /api/articles with only category param' do
    before do
      get '/api/articles',
      params: { category: "sport" }
    end
    
    it 'has a 200 response' do
      expect(response).to have_http_status 200
    end
  end
  
  describe 'GET /api/articles with location and category param' do
    before do
      get '/api/articles',
      params: { location: "Sweden", category: "sport" }
    end
    
    it 'has a 200 response' do
      expect(response).to have_http_status 200
    end
  end

  describe 'GET /api/articles with page param' do
    before do
      get '/api/articles',
      params: { page: 3 }
    end
    
    it 'has a 200 response' do
      expect(response).to have_http_status 200
    end
  end
end
