require 'rails_helper'

RSpec.describe 'Slack Bot Integration', type: :system do
  it 'shows incident list after Slack install' do    
    visit '/incidents'
    expect(page).to have_content("Incidents") 
  end
end
