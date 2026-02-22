# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "ruby_llm-cost"
  spec.version = "0.0.3"
  spec.authors = ["Scott Hardy"]
  spec.email = ["scott.the.hardy@gmail.com"]

  spec.summary = "Retrieves cost metadata for RubyLLM messages and chats"
  spec.homepage = "https://github.com/scott113341/ruby_llm-cost"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.4.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  spec.files = `git ls-files -z`.split("\x0")
  spec.require_paths = ["lib"]
end
