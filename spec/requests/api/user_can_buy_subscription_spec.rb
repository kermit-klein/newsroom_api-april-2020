require "stripe_mock"

RSpec.describe "POST /api/subscriptions", type: :request do
  let(:stripe_helper) { StripeMock.create_test_helper }
  before(:each) { StripeMock.start }
  after(:each) { StripeMock.stop }
  let(:valid_token) { stripe_helper.generate_card_token }

  let(:product) { stripe_helper.create_product }

  let!(:plan) do
    stripe_helper.create_plan(
      id: "dns_subscription",
      amount: 50000,
      currency: "usd",
      interval: "month",
      interval_count: 12,
      name: "DNS Subscription",
      product: product.id,
    )
  end

  let(:user) { create(:user) }
  let(:credentials) { user.create_new_auth_token }
  let(:headers) { { HTTP_ACCEPT: "application/json" }.merge!(credentials) }

  describe "with valid parameters" do
    before do
      post "/api/subscriptions",
        params: {
          stripeToken: valid_token,
        },
        headers: headers
    end

    it "set the subscriber attribute to true on successful transaction" do
      user.reload
      expect(user.role).to eq 'subscriber'
    end

    it "returns sucess http code" do
      expect(response).to have_http_status 200
    end

    it "returns success message" do
      expect(response_json["message"]).to eq "Transaction was successful"
    end
  end

  describe "with invalid parameters" do
    before do
      post "/api/subscriptions", headers: headers
    end

    it "returns error message" do
      expect(response_json["message"]).to eq "Transaction was NOT successful. There was no token provided..."
    end

    it "returns error http code" do
      expect(response).to have_http_status 422
    end

    it "does NOT set user role to subsciber" do
      user.reload
      expect(user.role).not_to eq 'subscriber'
    end
  end

  describe "stripeToken is empty" do
    before do
      post "/api/subscriptions",
           params: { stripeToken: "" }, headers: headers
    end

    it "returns a error http code" do
      expect(response).to have_http_status 422
    end

    it "does NOT set user role to subsciber" do
      user.reload
      expect(user.role).not_to eq 'subscriber'
    end

    it "returns an error message" do
      expect(response_json["message"]).to eq "Transaction was NOT successful. There was no token provided..."
    end
  end

  describe "credit card is declined" do
    before do
      StripeMock.prepare_card_error(:card_declined, :new_invoice)

      post "/api/subscriptions",
        params: { stripeToken: valid_token }, headers: headers
    end

    it "returns a error http code" do
      expect(response).to have_http_status 422
    end

    it "does NOT set user role to subsciber" do
      user.reload
      expect(user.role).not_to eq 'subscriber'
    end

    it "returns an error message" do
      expect(response_json["message"]).to eq "Transaction was NOT successful. The card was declined"
    end
  end

  describe "user is already subscriber" do
    let(:subscriber) { create(:user, role: :subscriber) }
    let(:subscriber_credentials) { subscriber.create_new_auth_token }
    let(:subscriber_headers) { { HTTP_ACCEPT: "application/json" }.merge!(subscriber_credentials) }
  
    before do
      post "/api/subscriptions",
        params: { stripeToken: valid_token }, headers: subscriber_headers
    end

    it "returns a error http code" do
      expect(response).to have_http_status 422
    end

    it "returns an error message" do
      expect(response_json["message"]).to eq "Transaction was NOT successful. You are already a subscriber"
    end
  end
end
