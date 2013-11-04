require 'graphviz'
require_relative 'transition.rb'
# Part of Nfa2Dfa module
module Nfa2Dfa
  # State of automaton
  class State
    attr_reader :id, :is_final, :graphviz_node, :is_starting

    def initialize(id)
      @id = id
      @is_final = false
      @transitions = []
      @graphviz_init = false
      @is_starting = false
    end

    def to_starting_node
      @is_starting = true
    end

    def to_s
      @id.to_s
    end

    def graph_id
      is_starting ? (@id + '/init') : @id
    end

    def to_graph_node(viz_graph)
      if @is_final
        @graphviz_node = viz_graph.add_nodes(
          graph_id, :shape => 'doublecircle')
      else
        @graphviz_node = viz_graph.add_nodes(graph_id, :shape => 'circle')
      end
      @graphviz_init = false
    end

    def finalize
      @is_final = true
    end

    def add_transition(tr)
      @transitions.insert(@transitions.size, tr)
    end

    def clear_transitions
      @transitions.clear
    end

    def associate_transitions(all_transitions)
      @transitions.clear
      @id.split(',').each do |id_part|
        all_transitions.each do |transition|
          if id_part == transition.beginning_state.id
            add_transition(transition)
          end
        end
      end
    end

    def get_next(char)
      ret_val = []
      @transitions.each do |trans|
        if trans.alphabet == char
          ret_val.insert(ret_val.size, trans.ending_state)
        end
      end
      ret_val
    end
  end
end
