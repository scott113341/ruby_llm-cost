# frozen_string_literal: true

require "json"
require "net/http"
require "uri"

module RubyLLM
  class Chat
    def message_cost(message)
      @_message_costs ||= {}

      if @provider.class != RubyLLM::Providers::OpenRouter
        raise "Only OpenRouter is supported for now"
      end

      @_message_costs[message] ||= get_message_cost(message)
    end

    def total_cost
      self
        .messages
        .map { |m| message_cost(m) }
        .compact
        .sum
    end

    def message_costs
      total_cost
      @_message_costs.clone
    end

    private

    def get_message_cost(message)
      # Messages sent *to* the LLM don't have a raw response
      if message.raw.nil?
        return 0.0
      end

      # Only OpenRouter is supported for now
      return nil unless URI(message.raw.url).host == "openrouter.ai"

      # OpenRouter's Generation API seems to not be read-after-write-consistent in that fetching
      # the generation sometimes 404's if you immediately fetch, hence the retries.
      begin
        with_retries(count: 60, sleep_for: 1) do
          gen_id = message.raw.body["id"]
          uri = URI("#{@provider.api_base}/generation?id=#{gen_id}")
          req = Net::HTTP::Get.new(uri, @provider.headers)

          res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
            http.request(req)
          end

          body = JSON.parse(res.body)
          body["data"]["total_cost"]
        end

      rescue
        # Return nil if cost-fetching permanently fails
        nil
      end
    end

    private

    def with_retries(count:, sleep_for: 0, &block)
      retries = 0

      begin
        block.call
      rescue => e
        if (retries += 1) < count
          warning = "Error: #{e.message}. Retrying (#{retries}/#{count}) after #{sleep_for.to_f}s"
          RubyLLM.logger.warn(warning)
          sleep(sleep_for.to_f)
          retry
        else
          RubyLLM.logger.warn("Error: #{e.message}. Out of retries")
          RubyLLM.logger.warn(e.backtrace)
          raise e
        end
      end
    end
  end
end
