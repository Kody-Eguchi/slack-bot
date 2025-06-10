require 'rails_helper'

RSpec.describe Incident, type: :model do
  describe 'validations' do
    it 'is valid with valid attribute' do
      incident = Incident.new(title: 'Something broke', severity: 'sev2', status: 'open')
      expect(incident).to be_valid
    end

    it 'is not valid without a title' do
      incident = Incident.new(title: nil, severity: 'sev2', status: 'open')
      expect(incident).not_to be_valid
    end

    it 'is valid without a sverity (optional)' do
      incident = Incident.new(title: 'No severity', severity: nil, status: 'open')
      expect(incident).to be_valid
    end

    it 'is not valid with an invalid severity' do
      incident = Incident.new(title: 'Invalid severity', severity: 'invalid', status: 'open')
      expect(incident).not_to be_valid
    end

    it 'is not valid with a invalid status' do
      incident = Incident.new(title: 'Bad status', severity: 'sev2', status: 'invalid')
      expect(incident).not_to be_valid
    end
  end
end