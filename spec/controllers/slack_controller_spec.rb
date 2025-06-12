require 'rails_helper'

RSpec.describe SlackController, type: :request do
  describe 'POST/slack/flag' do
    let(:text){ 'text' }
    let(:slack_event){{ user_id: 'U123', channel_id: 'C123', text: text }}

    context 'when text is missing' do
      let(:text) { nil }

      it 'returns bad request' do
        post "/slack/flag", params: slack_event
        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)["text"]).to eq('Invalid command format.')
      end
    end

    context 'when command is declare' do
      let(:text){ 'declare sev1 Login failing' }
      it 'calls SlackService.declare_incident' do
        expect(SlackService).to receive(:declare_incident).with(anything, hash_including('user_id' => 'U123'))
        post "/slack/flag", params: slack_event
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['text']).to eq("Incident declared")
      end
    end

    context 'when command is resolve' do
      let(:text) { 'resolve' }

      it 'calls SlackService.resolve_incident' do
        expect(SlackService).to receive(:resolve_incident).with(hash_including("user_id" => "U123"))
        post '/slack/flag', params: slack_event
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['text']).to eq("Incident resolved")
      end
    end

    context 'when command is unknown' do
      let(:text) { 'foobar' }

      it 'returns unknown command error' do
        post '/slack/flag', params: slack_event
        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)["text"]).to include("Unknown command")
      end
    end

  end
end