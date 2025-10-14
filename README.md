# RubyLLM Cost

Gets the true cost of RubyLLM Chats. Only OpenRouter is supported, for now.

To use, add to your `Gemfile`:

```ruby
gem 'ruby_llm-cost', git: 'https://github.com/scott113341/ruby_llm-cost'
```

And require in your code:

```ruby
require 'ruby_llm/cost'

chat = RubyLLM.chat
ans_1 = chat.ask('Why did the keyboard cross the road?')
ans_2 = chat.ask('Make your answer better!')

cost_1 = chat.message_cost(ans_1) # Something like 0.000351153
cost_2 = chat.message_cost(ans_2) # Something like 0.001305216

total_cost = chat.total_cost # Equal to cost_1 + cost_2

# Returns a Hash of all 4 messages (2 TO the LLM; 2 FROM the LLM) and their costs.
# The keys are RubyLLM::Message instances.
# {
#   RubyLLM::Message<"Why did the keyboard cross the road?"> => 0.0,
#   RubyLLM::Message<"To get to the other space!"> => 0.000351153,
#   RubyLLM::Message<"Make your answer better!"> => 0.0,
#   RubyLLM::Message<"To get to the other site!"> => 0.001305216,
# }
message_costs = chat.message_costs
```
