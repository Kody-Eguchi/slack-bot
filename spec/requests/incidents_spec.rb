require 'rails_helper'

RSpec.describe "Incidents", type: :request do
  let(:user) { User.create!(email: "test@example.com", password: "password", slack_user_id: "U12345") }

  let(:valid_attributes) do
    {
      title: 'Database outage',
      severity: 'sev1',
      status: 'open',
      slack_user_id: user.slack_user_id
    }
  end

  let(:invalid_attributes) do
    {
      title: "",
      severity: "invalid",
      status: "closed",
      slack_user_id: user.slack_user_id
    }
  end

  describe "GET /incidents" do
    it "returns a successful response" do
      Incident.create!(valid_attributes)
      get "/incidents"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /incidents/new" do
    it "returns a successful response" do
      get new_incident_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /incidents/:id" do
    let!(:incident) { Incident.create!(valid_attributes) }

    context "when incident exists" do
      it "returns a successful response" do
        get incident_path(incident)
        expect(response).to have_http_status(:ok)
      end
    end

    context "when incident does not exist" do
      it "returns not found (404)" do
        get "/incidents/999999999"
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "GET /incidents/:id/edit" do
    let!(:incident) { Incident.create!(valid_attributes) }

    context "when incident exists" do
      it "returns a successful response" do
        get edit_incident_path(incident)
        expect(response).to have_http_status(:ok)
      end
    end

    context "when incident does not exist" do
      it "returns not found (404)" do
        get "/incidents/999999999/edit"
        expect(response).to have_http_status(:not_found)
      end
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

    context "with invalid parameters" do
      it "does not update the incident and returns unprocessable entity" do
        original_title = incident.title
        original_severity = incident.severity

        patch "/incidents/#{incident.id}", params: {
          incident: {
            title: "",         # Invalid: blank
            severity: "wrong"  # Invalid: not a valid enum
          }
        }

        incident.reload
        expect(response).to have_http_status(:unprocessable_entity)

        expect(incident.title).to eq(original_title)
        expect(incident.severity).to eq(original_severity)
      end
    end
  end

  describe "DELETE /incidents/:id" do
    context "when incident exists" do
      let!(:incident) { Incident.create!(valid_attributes) }

      it "deletes the incident" do
        expect {
          delete "/incidents/#{incident.id}"
        }.to change(Incident, :count).by(-1)
        expect(response).to have_http_status(:no_content).or have_http_status(:redirect)
      end
    end

    context "when incident does not exist" do
      it "does not delete anything and returns not found (404)" do
        expect {
          delete "/incidents/999999999"
        }.not_to change(Incident, :count)
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "Sorting" do
    before { Incident.delete_all }

    it "sorts by created_at descending by default" do
      older = Incident.create!(title: "Older", severity: "sev1", created_at: 2.days.ago)
      newer = Incident.create!(title: "Newer", severity: "sev1", created_at: 1.day.ago)

      get "/incidents", params: { sort: "created_at", direction: "desc" }
      expect(response.body).to match(/Newer.*Older/m)
    end

    it "sorts by created_at ascending" do
      older = Incident.create!(title: "Older", severity: "sev1", created_at: 2.days.ago)
      newer = Incident.create!(title: "Newer", severity: "sev1", created_at: 1.day.ago)

      get "/incidents", params: { sort: "created_at", direction: "asc" }
      expect(response.body).to match(/Older.*Newer/m)
    end

    it "sorts incidents alphabetically A-Z" do
      Incident.create!(title: "Bravo", severity: "sev1")
      Incident.create!(title: "Alpha", severity: "sev1")

      get "/incidents", params: { sort: "title", direction: "asc" }
      expect(response.body).to match(/Alpha.*Bravo/m)
    end

    it "sorts incidents alphabetically Z-A" do
      Incident.create!(title: "Bravo", severity: "sev1")
      Incident.create!(title: "Alpha", severity: "sev1")

      get "/incidents", params: { sort: "title", direction: "desc" }
      expect(response.body).to match(/Bravo.*Alpha/m)
    end

    it "does not crash when database is empty and sorting is applied" do
      get "/incidents", params: { sort: "created_at", direction: "desc" }
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("incidents").or include("Incident")
    end
  end

end
