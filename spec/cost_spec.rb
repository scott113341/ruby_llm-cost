# frozen_string_literal: true

require "spec_helper"

RSpec.describe RubyLLM::Chat, :vcr do
  before(:each) do
    RubyLLM.configure do |config|
      config.openrouter_api_key = ENV.fetch("OPENROUTER_API_KEY", "FAKE")
      config.default_model = "openai/gpt-5-nano"
    end
  end

  let(:chat) do
    VCR.use_cassette("chat") do
      chat = RubyLLM.chat
      chat.ask("Why did the keyboard cross the road?")
      chat.ask("Turn the Dad Joke level up to 11")
      chat
    end
  end

  let(:m_1_cost) { 0.000351153 }
  let(:m_3_cost) { 0.001305216 }

  describe "#message_cost" do
    it "returns the (zero) cost of a message sent to OpenRouter" do
      message = chat.messages[0]
      expect(message.content).to(eq("Why did the keyboard cross the road?"))
      expect(chat.message_cost(message)).to(eq(0.0))
    end

    it "returns the cost of an OpenRouter message" do
      message = chat.messages[1]
      expect(message.content).to(start_with("Here are a few punchlines you can use"))
      expect(chat.message_cost(message)).to(eq(m_1_cost))
    end

    it "returns the cost of the OpenRouter messages" do
      expect(chat.message_cost(chat.messages[1])).to(eq(m_1_cost))
      expect(chat.message_cost(chat.messages[3])).to(eq(m_3_cost))
    end

    it "returns nil if the cost-fetching permanently fails" do
      allow(chat).to(receive(:with_retries).and_raise("Skip"))
      expect(chat.message_cost(chat.messages[1])).to(eq(nil))
    end

    it "uses the cached value when present" do
      message = chat.messages[1]

      # Before calling #message_cost
      expect(chat.instance_variable_get(:@_message_costs)).to(be_nil)
      expect(chat.message_cost(message)).to(eq(m_1_cost))

      # After calling #message_cost
      expect(chat.instance_variable_get(:@_message_costs)).to(
        eq(
          {
            message => m_1_cost
          }
        )
      )

      # Modify the cached value
      chat.instance_variable_get(:@_message_costs)[message] = 0.123123

      # Assert the cached value is used
      expect(chat.message_cost(message)).to(eq(0.123123))
    end
  end

  describe "#total_cost" do
    it "returns the total cost of the chat" do
      expect(chat.total_cost).to(eq(m_1_cost + m_3_cost))
    end
  end

  describe "#message_costs" do
    it "returns a Hash of message costs" do
      expect(chat.message_costs).to(
        eq(
          {
            chat.messages[0] => 0.0,
            chat.messages[1] => m_1_cost,
            chat.messages[2] => 0.0,
            chat.messages[3] => m_3_cost
          }
        )
      )
    end
  end
end
