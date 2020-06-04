# frozen_string_literal: true

RSpec.describe 'Api::Admin::Articles :update', type: :request do
  let(:editor) { create(:user, role: 'editor') }
  let(:article) { create(:article, location: 'Sweden') }
  let(:editors_credentials) { editor.create_new_auth_token }
  let(:editors_headers) { { HTTP_ACCEPT: 'application/json' }.merge!(editors_credentials) }

  describe 'editor successfully add location option' do
    before do
      put "/api/admin/articles/#{article.id}",
          headers: editors_headers,
          params: { activity: 'PUBLISH', premium: true, category: 'economy', location: 'Sweden', international: false }
      article.reload
    end

    it 'gives a success message' do
      expect(response_json['message']).to eq 'Article successfully published!'
    end

    it 'has set location to Sweden' do
      expect(article.location).to eq 'Sweden'
    end

    it 'gives success status' do
      expect(response).to have_http_status 200
    end

    it 'has set international to false' do
      expect(article.international).to eq false
    end
  end

  describe 'editor publishes without location' do
    let(:article) { create(:article) }
    before do
      put "/api/admin/articles/#{article.id}",
          headers: editors_headers,
          params: { activity: 'PUBLISH' }
      article.reload
    end

    it 'gives an ok response' do
      expect(response).to have_http_status 200
    end

    it 'sets :international to true' do
      expect(article.international).to eq true
    end
  end

  describe 'editor tries to set invalid location' do
    let(:article) { create(:article, location: 'elsewhere') }
    before do
      put "/api/admin/articles/#{article.id}",
          headers: editors_headers,
          params: { activity: 'PUBLISH', location: 'elsewhere' }
      article.reload
    end

    it 'gives an error code' do
      expect(response).to have_http_status 422
    end

    it 'gives an error message' do
      expect(response_json['message']).to eq "'elsewhere' is not a valid location"
    end
  end
end
