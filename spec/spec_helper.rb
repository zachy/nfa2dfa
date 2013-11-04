#!/usr/bin/env ruby
require_relative '../lib/nfa2dfa.rb'

RSpec.configure do |config|
  config.color_enabled = true
end

class Automaton  < Nfa2Dfa::Automaton
end
class State < Nfa2Dfa::State
end
class Transition < Nfa2Dfa::Transition
end
