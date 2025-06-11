require 'rails_helper'

RSpec.describe "Incidents", type: :request do
  let(:valid_attributes) do
    {
      title: 'Database outage',
      severity: 'sev1',
      status: 'open'
    }
  end

  let(:invalid_attributes) do
    {
      title: "",
      severity: "invalid",
      status: "closed"
    }
  end

  describe "GET /incidents" do
    it "returns a successful response" do
      Incident.create!(valid_attributes)
      get "/incidents"
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST/incidents' do
    context "with valid parameters" do
      it 'creates a new Incident' do
        expect {
          post "/incidents", params: { incident: valid_attributes }
        }.to change(Incident, :count).by(1)
        expect(response).to have_http_status(:created).or have_http_status(:redirect)
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Incident' do
        expect {
          post '/incidents', params: { incident: invalid_attributes }
      }.not_to change(Incident, :count)
      expect(response).to have_http_status(:unprocessable_entity). or have_http_status(:bad_request)
      end
    end
  end

  describe 'PATCH/incidents/:id' do
    let!(:incident) { Incident.create!(valid_attributes) }

    it "updates the incident" do
      patch "/incidents/#{incident.id}", params: { incident: { status: "resolved" } }
      expect(response).to have_http_status(:ok).or have_http_status(:redirect)
      expect(incident.reload.status).to eq("resolved")
    end
  end

  describe "DELETE /incidents/:id" do
    let!(:incident) { Incident.create!(valid_attributes) }

    it "deletes the incident" do
      expect {
        delete "/incidents/#{incident.id}"
      }.to change(Incident, :count).by(-1)
      expect(response).to have_http_status(:no_content).or have_http_status(:redirect)
    end
  end

end
