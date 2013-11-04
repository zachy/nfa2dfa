require 'graphviz'
require_relative 'state.rb'
# Part of Nfa2Dfa module
module Nfa2Dfa
  # Transition between states
  class Transition

    attr_reader :beginning_state, :alphabet, :ending_state

    def initialize(beg_state, alphabet, end_state)
      @beginning_state = beg_state
      @alphabet = alphabet
      @ending_state = end_state
    end

    def to_graph_transition(graphviz_graph)
      graphviz_graph.add_edges(
        @beginning_state.graphviz_node,
        @ending_state.graphviz_node, :label => @alphabet)
    end

    def to_s
      ret = @beginning_state.to_s + '-' + alphabet + '-' + @ending_state.to_s
      ret
    end

    def print
      puts @beginning_state.id + '-' + @alphabet + '-' + @ending_state.id
    end
  end
end
