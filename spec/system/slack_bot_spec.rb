require 'rails_helper'

RSpec.describe 'Slack Bot Integration', type: :system do
  it 'shows incident list after Slack install' do    
    visit '/incidents'
    expect(page).to have_content("Incidents") 
  end

  it 'shows incident list after visitng /incidents' do
    Incident.create!(title: 'Login fail', severity: 'sev1', status: 'open')
    visit '/incidents'
    expect(page).to have_content("Login fail")
    expect(page).to have_content("sev1")
  end

  it 'displays a declared incident' do
    Incident.create!(
      title: 'API outage',
      severity: 'sev0',
      status: 'open',
    )

    visit '/incidents'

    expect(page).to have_content('API outage')
    expect(page).to have_content('sev0')
    expect(page).to have_content('open')
  end

  it 'shows resolved status for a resolved incident' do
    incident = Incident.create!(
      title: 'DB down',
      severity: 'sev1',
      status: 'resolved',
    )

    visit '/incidents'

    expect(page).to have_content('DB down')
    expect(page).to have_content('resolved')
  end
end
