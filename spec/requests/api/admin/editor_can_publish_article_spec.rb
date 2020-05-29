RSpec.describe 'Api::Admin::Articles :update', type: :request do
  let!(:article) { create(:article) }
  let(:editor) { create(:user, role: 'editor') }
  let(:editors_credentials) { editor.create_new_auth_token }
  let(:editors_headers) { { HTTP_ACCEPT: 'application/json' }.merge!(editors_credentials) }

  let(:journalist) { create(:user, role: 'journalist') }
  let(:journalist_credentials) { journalist.create_new_auth_token }
  let(:journalist_headers) { { HTTP_ACCEPT: 'application/json' }.merge!(journalist_credentials) }

  before do
    put "/api/admin/articles/#{article.id}", headers: editors_headers, params: { activity: "PUBLISH", premium: true, category: 'economy' }
    article.reload()
  end

  describe 'editor successfully updates and' do
    it 'gives a success code' do
      expect(response).to have_http_status 200
    end

    it 'gives a success message' do
      expect(response_json['message']).to eq "Article successfully published!"
    end

    it 'has set published to true' do
      expect(article.published).to eq true
    end

    it 'has set category to economy' do
      expect(article.published).to eq true
    end

    it 'has set premium to true' do
      expect(article.published).to eq true
    end
  end

  describe 'journalist cannot update articles' do
    before do
      put "/api/admin/articles/#{article.id}", headers: journalist_headers, params: { activity: "PUBLISH", premium: true, category: 'economy' }
    end

    it 'has a 401 response' do
      expect(response).to have_http_status 401
    end

    it 'and an error message' do
      expect(response_json['errors'][0]).to eq "You are not authorized"
    end
  end

  describe 'visitors cannot update articles' do
    before do
      put "/api/admin/articles/#{article.id}", params: { activity: "PUBLISH", premium: true, category: 'economy' }
    end

    it 'has a 401 response' do
      expect(response).to have_http_status 401
    end

    it 'and an error message' do
      expect(response_json['errors'][0]).to eq "You are not authorized"
    end
  end
end