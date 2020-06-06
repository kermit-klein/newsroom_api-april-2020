# frozen_string_literal: true

RSpec.describe 'Api::Articles :index', type: :request do
  categories = Article.categories.keys
  categories.each do |category|
    let!("#{category}_articles".to_sym) { 4.times { create(:article, category: category) } }
  end
  let!(:extra_swedish_sport_articles) { 9.times { create(:article, location: 'Sweden', international: false) } }
  let!(:extra_swedish_international_sport_articles) { 11.times { create(:article, location: 'Sweden', international: true, published_at: Time.now - 5.days) } }
  let!(:extra_international_sport_articles) { 13.times { create(:article, location: nil, international: true) } }
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
      expect(response_json['articles'].length).to eq 24
    end

    it 'returns only published articles' do
      response_json['articles'].each do |article|
        expect(article['published_at']).not_to eq nil
      end
    end

    it 'returns only international articles' do
      response_json['articles'].each do |article|
        expect(article['international']).to eq true
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

    describe 'response does not have keys' do
      it ':created_at' do
        expect(response_json['articles'][0]).not_to have_key 'created_at'
      end

      it ':updated_at' do
        expect(response_json['articles'][0]).not_to have_key 'updated_at'
      end
    end
  end

  describe 'GET /api/articles with good params...' do
    it 'page, location (57 items)' do
      get '/api/articles', params: { location: 'Sweden', page: 3 }
      expect(response_json['articles'].length).to eq 9
    end

    it 'page, category  (28 items)' do
      get '/api/articles', params: { category: 'sport', page: 2 }
      expect(response_json['articles'].length).to eq 4
    end

    it 'page, location, category (37 items)' do
      get '/api/articles', params: { category: 'sport', location: 'Sweden', page: 2 }
      expect(response_json['articles'].length).to eq 13
    end

    it 'category: current (37 items)' do
      get '/api/articles', params: { category: 'current', page: 2 }
      expect(response_json['articles'].length).to eq 13
    end

    it 'category: local, location: Sweden (20 items)' do
      get '/api/articles', params: { category: 'local', location: 'Sweden' }
      expect(response_json['articles'].length).to eq 20
    end

    it 'category: local, no location (13 items)' do
      get '/api/articles', params: { category: 'local' }
      expect(response_json['articles'].length).to eq 13
    end
  end

  describe 'GET /api/articles with bad params...' do
    it 'bad page' do
      get '/api/articles', params: { location: 13, page: 'sa' }
      expect(response_json['message']).to eq 'Page parameter must be a positive integer'
    end

    it 'bad category' do
      get '/api/articles', params: { category: 'music' }
      expect(response_json['message'])
        .to eq 'Category parameter must be omitted or one of the following: other, sport, politics, economy, world, entertainment, current, local'
    end

    it 'bad location' do
      get '/api/articles', params: { location: [] }
      expect(response_json['message']).to eq 'Location parameter must be a string'
    end
  end

  describe 'GET /api/articles tells you if there is more content' do
    it 'tells you there is another page to fetch' do
      get '/api/articles', params: { category: 'sport' }
      expect(response_json['next_page']).to eq 2
    end

    it 'tells you there is not another page to fetch' do
      get '/api/articles', params: { category: 'sport', page: 2 }
      expect(response_json['next_page']).to eq nil
    end
  end
end
