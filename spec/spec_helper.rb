# frozen_string_literal: true

require "active_support/all"
require "dotenv/load"
require "ruby_llm"
require "vcr"
require "webmock/rspec"

require "ruby_llm/cost"

RSpec.configure do |config|
  config.example_status_persistence_file_path = nil
end

VCR.configure do |c|
  c.hook_into(:webmock)
  c.cassette_library_dir = File.expand_path("cassettes", __dir__)
  c.configure_rspec_metadata!

  if ENV["OPENROUTER_API_KEY"]
    c.filter_sensitive_data("<OPENROUTER_API_KEY>") { ENV["OPENROUTER_API_KEY"] }
  end

  c.default_cassette_options = {
    record: :once,
    match_requests_on: [:method, :uri, :body],
    drop_unused_requests: true
  }
end
