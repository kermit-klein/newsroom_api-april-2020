# frozen_string_literal: true

RSpec.describe 'Api::Articles :index', type: :request do
  let!(:article) { 3.times { create(:article) } }
  let!(:article) { 5.times { create(:article, published: true, published_at: Time.now) } }

  describe 'GET /api/articles' do
    before do
      get '/api/articles'
    end

    it 'has a 200 response' do
      expect(response).to have_http_status 200
    end

    it 'returns all published articles' do
      expect(response_json['articles'].length).to eq 5
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
end
