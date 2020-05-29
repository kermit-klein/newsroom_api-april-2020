require 'stripe_mock'

RSpec.describe 'POST /api/subscriptions', type: :request do
  let(:stripe_helper) { StripeMock.create_test_helper }
  before(:each) { StripeMock.start }
  after(:each) { StripeMock.stop }
  let(:valid_token) { stripe_helper.generate_card_token }
  
  let(:product) { stripe_helper.create_product(id: "my_plan") }

  let!(:plan) do
    stripe_helper.create_plan(
      id: 'dns_subscription',
      amount: 50000,
      currency: 'usd',
      interval: 'month',
      interval_count: 12,
      name: 'DNS Subscription',
      product: product.id
    )
  end

  let(:user) {create(:user)}
  let(:credentials) { user.create_new_auth_token }
  let(:headers) { {HTTP_ACCEPT: 'application/json' }.merge!(credentials)}

    describe 'with valid parameters' do
      before do
        post '/api/subscriptions',
          params: {
            stripeToken: valid_token
          },
          headers: headers
      end

      it 'set the subscriber attribute to true on successful transaction' do
        user.reload
        expect(user.subscriber).to eq true
      end

      it 'returns sucess http code' do
        expect(response).to have_http_status 200
      end

      it 'returns success message' do
        expect(response_json['message']).to eq 'Transaction was successful'
      end
    end

    describe 'with invalid parameters' do
      before do
        post '/api/subscriptions', headers: headers
      end

      it 'returns error message' do
        expect(response_json['message']).to eq 'Transaction was NOT successful. There was no token provided...'
      end

      it 'returns error http code' do
        expect(response).to have_http_status 422
      end

      it 'does not set the subscriber attribute to true' do
        user.reload
        expect(user.subscriber).not_to eq true
      end
    end

end