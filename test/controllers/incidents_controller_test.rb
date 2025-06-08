require "test_helper"

class IncidentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @incident = incidents(:one)
  end

  test "should get index" do
    get incidents_url
    assert_response :success
  end

  test "should get new" do
    get new_incident_url
    assert_response :success
  end

  test "should create incident" do
    assert_difference("Incident.count") do
      post incidents_url, params: { incident: { title: "Slack outage", description: "Messages not sending", severity: "sev1" }} 
    end

    assert_redirected_to incident_url(Incident.last)
  end

  test "should show incident" do
    get incident_url(@incident)
    assert_response :success
  end

  test "should get edit" do
    get edit_incident_url(@incident)
    assert_response :success
  end

  test "should update incident" do
    patch incident_url(@incident), params: { incident: { status: "resolved" } }
    assert_redirected_to incident_url(@incident)
  end

  test "should destroy incident" do
    assert_difference("Incident.count", -1) do
      delete incident_url(@incident)
    end

    assert_redirected_to incidents_url
  end

  test "should sort by created_at descending by default" do
    Incident.destroy_all
    older = Incident.create!(title: "Older", created_at: 2.days.ago)
    newer = Incident.create!(title: "Newer", created_at: 1.day.ago)

    get incidents_url(sort: "created_at", direction: "desc")
    assert_response :success
    assert_match(/Newer.*Older/m, response.body)
  end

  test "should sort bt created_at ascending" do
    Incident.destroy_all
    older = Incident.create!(title: "Older", created_at: 2.days.ago)
    newer = Incident.create!(title: "Newer", created_at: 1.day.ago)

    get incidents_url(sort: "created_at", direction: "asc")
    assert_response :success
    assert_match(/Older.*Newer/m, response.body)
  end

  test "should sort incidents alphabetically A-Z" do
    Incident.destroy_all
    b_incident = Incident.create!(title: "Bravo")
    a_incident = Incident.create!(title: "Alpha")

    get incidents_url(sort: "title", direction: "asc")
    assert_response :success
    assert_match(/Alpha.*Bravo/m, response.body)
  end

  test "should sort incidents alphabetically Z-A" do
    Incident.destroy_all
    b_incident = Incident.create!(title: "Bravo")
    a_incident = Incident.create!(title: "Alpha")

    get incidents_url(sort: "title", direction: "desc")
    assert_response :success
    assert_match(/Bravo.*Alpha/m, response.body)
  end

  test "should not crash when database is empty and sorting is applied" do
    Incident.delete_all

    get incidents_url(sort: "created_at", direction: "desc")
    assert_response :success
    assert_select "turbo-frame#incidents"
  end
end
