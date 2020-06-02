RSpec.describe 'Api::Admin::Articles :update', type: :request do 
  let(:editor) { create(:user, role: 'editor') }
  let(:article) {create(:article, location: 'Sweden')}
  let(:editors_credentials) { editor.create_new_auth_token }
  let(:editors_headers) { { HTTP_ACCEPT: 'application/json' }.merge!(editors_credentials) }

  let(:journalist) { create(:user, email: "asd@asd.com", role: 'journalist') }
  let(:journalist_credentials) { journalist.create_new_auth_token }
  let(:journalist_headers) { { HTTP_ACCEPT: 'application/json' }.merge!(journalist_credentials) }

  describe 'editor successfully add location option' do 
    before do 
      put "/api/admin/articles/#{article.id}",
    headers: editors_headers,
    params: {activity: "PUBLISH",premium: true , category: 'economy', location: "Sweden"}
    article.reload()
  end

   it 'gives a success message' do 
   expect(response_json['message']).to eq "Article successfully published!"
   end

    it'has set location to Sweden' do 
    expect(article.location).to eq 'Sweden'
    end

    it 'gives success status' do
      expect(response).to have_http_status 200
    end
  end

    describe 'editor unsuccessfully set location'do 
    let(:article) {create(:article, location: 'elsewhere')}
      before do
        put "/api/admin/articles/#{article.id}", 
        headers: editors_headers,
        params: {activity: "PUBLISH", location: "elsewhere"}
        article.reload()
      end
    
    it 'gives an error code' do
    expect(response).to have_http_status 422
    end

    it 'gives an error message' do
    expect(response_json['message']).to eq "elsewhere, not a valid location"

    end
  end
end 
