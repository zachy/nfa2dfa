
require 'graphviz'
require_relative 'state.rb'

module Nfa2Dfa
  class Transition
  
    attr_reader :beginning_state, :alphabet, :ending_state
  
    def initialize(beg_state, alphabet, end_state)
      @beginning_state = beg_state
      @alphabet = alphabet
      @ending_state = end_state
    end
  
    def to_graph_transition(graphviz_graph)
      graphviz_graph.add_edges( @beginning_state.graphviz_node, @ending_state.graphviz_node, :label => @alphabet)
    end
  
    def print
      puts @beginning_state.id + "-" + @alphabet + "-" + @ending_state.id
    end
  end
end