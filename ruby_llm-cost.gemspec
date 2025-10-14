# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "ruby_llm-cost"
  spec.version = "0.0.1"
  spec.authors = ["Scott Hardy"]
  spec.email = ["scott.the.hardy@gmail.com"]

  spec.summary = "Retrieves cost metadata for RubyLLM messages and chats"
  spec.homepage = "https://github.com/scott113341/ruby_llm-cost"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.4.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[.github/ spec/ Gemfile])
    end
  end

  spec.require_paths = ["lib"]
end
