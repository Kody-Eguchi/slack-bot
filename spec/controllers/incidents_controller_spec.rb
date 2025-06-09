require 'rails_helper'

RSpec.describe "Incidents", type: :request do
  let!(:incident) { Incident.create!(title: "Sample Incident", description: "Sample Description", severity: "sev1") }

  describe "GET /index" do
    it "returns http success" do
      get incidents_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get new_incident_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /create" do
    it "creates a new incident" do
      expect {
        post incidents_path, params: { incident: { title: "Slack outage", description: "Messages not sending", severity: "sev1" } }
      }.to change(Incident, :count).by(1)

      expect(response).to redirect_to(incident_path(Incident.last))
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get incident_path(incident)
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /edit" do
    it "returns http success" do
      get edit_incident_path(incident)
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /update" do
    it "updates the incident and redirects" do
      patch incident_path(incident), params: { incident: { status: "resolved" } }
      expect(response).to redirect_to(incident_path(incident))
    end
  end

  describe "DELETE /destroy" do
    it "deletes the incident and redirects" do
      delete_incident = Incident.create!(title: "To Be Deleted", description: "desc", severity: "sev1")
      expect {
        delete incident_path(delete_incident)
      }.to change(Incident, :count).by(-1)
      expect(response).to redirect_to(incidents_path)
    end
  end

  describe "Sorting" do
    before { Incident.delete_all }

    it "sorts by created_at descending by default" do
      older = Incident.create!(title: "Older", created_at: 2.days.ago)
      newer = Incident.create!(title: "Newer", created_at: 1.day.ago)

      get incidents_path(sort: "created_at", direction: "desc")
      expect(response.body).to match(/Newer.*Older/m)
    end

    it "sorts by created_at ascending" do
      older = Incident.create!(title: "Older", created_at: 2.days.ago)
      newer = Incident.create!(title: "Newer", created_at: 1.day.ago)

      get incidents_path(sort: "created_at", direction: "asc")
      expect(response.body).to match(/Older.*Newer/m)
    end

    it "sorts incidents alphabetically A-Z" do
      Incident.create!(title: "Bravo")
      Incident.create!(title: "Alpha")

      get incidents_path(sort: "title", direction: "asc")
      expect(response.body).to match(/Alpha.*Bravo/m)
    end

    it "sorts incidents alphabetically Z-A" do
      Incident.create!(title: "Bravo")
      Incident.create!(title: "Alpha")

      get incidents_path(sort: "title", direction: "desc")
      expect(response.body).to match(/Bravo.*Alpha/m)
    end

    it "does not crash when database is empty and sorting is applied" do
      Incident.delete_all

      get incidents_path(sort: "created_at", direction: "desc")
      expect(response).to have_http_status(:success)
      expect(response.body).to include("incidents")
    end
  end
end
