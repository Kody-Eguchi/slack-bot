require 'rails_helper'

RSpec.describe Incident, type: :model do
  it 'is invalid without a title' do
    incident = Incident.new(title: nil)
    expect(incident).not_to be_valid
  end
end