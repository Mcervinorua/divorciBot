require 'spec_helper'
require 'rack/test'
require_relative '../app.rb'

describe "app" do
  include Rack::Test::Methods

  module App
    class << self
      def dialogues
      end
      def redis
        MockRedis.new
      end
      def telegram_token
      end
    end
  end

  def app
    builder = Rack::Builder.new
    builder.run BotWebhookController.new
  end

  let(:valid_payload) { {message: {chat: { id: "123"} } }.to_json }

  describe 'routing' do
    describe '/message' do
      it 'returns 200' do
        a_bot = double(:bot, new_message: nil)
        allow(DialogueRunner).to receive(:new).
          and_return(a_bot)

        post '/message', valid_payload

        expect(last_response).to be_ok
      end

      it 'calls the bot' do
        a_bot = double(:bot, new_message: nil)
        allow(DialogueRunner).to receive(:new).
          and_return(a_bot)

        expect(a_bot).to receive(:new_message)

        post '/message', valid_payload
      end
    end

    it 'return 404 when the path in invalid' do
      post '/invalid_path'

      expect(last_response).to be_not_found
    end
  end
end
