require 'rails_helper'

RSpec.describe "SlackAuthController", type: :request do
  describe "GET /slack/install" do
    it "redirects to Slack OAuth URL" do
      get "/slack/install"
      expect(response).to redirect_to(/https:\/\/slack.com\/oauth\/v2\/authorize\?/)
    end
  end

  describe "GET /slack/oauth/callback" do
    context "when no code param is given" do
      it "returns a 400 bad request" do
        get "/slack/oauth/callback"
        expect(response).to have_http_status(:bad_request)
        expect(response.body).to include("Authorization code missing")
      end
    end

    context "when valid code is given" do
      before do
        # Mock Redis server access
        allow(Redis).to receive(:new).and_return(double(ping: "PONG"))
        # Mock Slack API request
        stub_request(:post, "https://slack.com/api/oauth.v2.access").
          to_return(
            body: {
              ok: true,
              access_token: "xoxb-123",
              team: { id: "T123", name: "Test Team" }
            }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it "stores access token and renders index" do
        get "/slack/oauth/callback", params: { code: "valid_code" }
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Test Team")
      end
    end
  end
end
