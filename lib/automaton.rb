require 'graphviz'
require_relative 'state.rb'
require_relative 'transition.rb'
# Part of Nfa2Dfa module
module Nfa2Dfa
  # Representation of Automaton
  class Automaton

    public

    def to_str
      ret_val = ''
      str = ''
      ret_val += item_to_str(@states) + "\n" + item_to_str(@alphabet) +
        "\n" + item_to_str(@transitions) + "\n"
      ret_val += @starting_state.id + "\n"
      @states.each do |state|
        state.is_final ? str += state.id + ' ' : nil
      end
      ret_val += str.byteslice(0, str.length - 1)
      ret_val
    end

    def to_graph(path)
      g = GraphViz.new(:G, :type => :digraph)
      @states.each do |state|
        state.to_graph_node(g)
      end
      @transitions.each do |trans|
        trans.to_graph_transition(g)
      end
      g.output(:png => path)
    end

    def self.init(path)
      File.file?(path) ? nil : (return nil)
      data_arr = []
      index = 0
      File.open(path).each_line do |line|
        data_arr[index] = line
        index = index + 1
      end
      validate(data_arr) ? get_valid_input(data_arr) : (return nil)
    end

    def self.validate(data_arr)
      parsed = []
      data_arr.each do |item|
        parsed.push item.split(' ')
      end
      validate_transitions(parsed[0], parsed[1], parsed[2]) &&
        validate_states(parsed[0], parsed[3], parsed[4])
    end

    def accepts?(data)
      formatted_input = data.split(' ')
      @stack = []
      @stack.push(@starting_state)
      if formatted_input.size == 0
        @starting_state.is_final
      else
        recurs_accepts?(formatted_input, 0)
      end
    end

    def deterministic?
      @states.each do |state|
        @alphabet.each do |char|
          state.get_next(char).size > 1 ? (return false) : nil
        end
      end
      true
    end

    def determine
      deterministic? ? self : determine_prot
    end

    protected

    attr_accessor :states, :alphabet, :transitions, :starting_state, :stack

    def recurs_accepts?(data, index)
      ret_val = false
      @stack.size == 0 ? (return false) : nil
      cnt = resolve_state_on_stack(data[index])
      index += 1
      if index == data.size
        cnt.times { @stack.pop.is_final ? ret_val = true : nil }
      else
        return recurs_accepts?(data, index)
      end
      ret_val
    end

    def self.get_valid_input(data_arr)
      states = []
      data_arr[0].split(' ').each { |wrd| states.push State.new(wrd) }
      fin = data_arr[4].split(' ')
      states.each { |st| fin.include?(st.id) ? st.finalize : NIL }
      alphabet = []
      data_arr[1].split(' ').each { |wrd| alphabet.insert(alphabet.size, wrd) }
      transitions = []
      data_arr[2].split(' ').each do |wrd|
        trans = wrd.split('-')
        state1 = NIL
        state2 = NIL
        states.each do |item|
          trans[0] == item.id ? state1 = item : NIL
          trans[2] == item.id ? state2 = item : NIL
          state1 != NIL && state2 != NIL ? break : NIL
        end
        transitions.insert(transitions.size, Transition.new(
            state1, trans[1], state2))
        state1.add_transition(transitions[transitions.size - 1])
      end
      starting = NIL
      states.each do |item2|
        if item2.id == data_arr[3].split(' ')[0]
          starting = item2
          item2.to_starting_node
          break
        end
      end
      Automaton.new(states, alphabet, transitions, starting)
    end

# main determinization function
    def determine_prot
      undetermined_states = []
      determined_states = []
      transits = []
      tot_transits = []
      curr_states = []
      undetermined_states[0] = @starting_state.clone
      new_begin_state = undetermined_states[0]
      while undetermined_states.size > 0
        temp_state = undetermined_states[0]
        curr_states.clear
        transits.clear
        @alphabet.each do |char|
          t_states_by_char = temp_state.get_next(char)
          if t_states_by_char.size > 0
            state_id = merge_state_names(t_states_by_char)
            state = find_state(
              state_id, determined_states, undetermined_states)
            if state
              transits.push(Transition.new(temp_state, char, state))
              tot_transits.push(Transition.new(temp_state, char, state))
            else
              state = State.new(state_id)
              state.associate_transitions(@transitions)
              undetermined_states.push(state)
              transits.push(Transition.new(temp_state, char, state))
              tot_transits.push(Transition.new(temp_state, char, state))
            end
          end
        end
        temp_state.clear_transitions
        transits.each do |transit|
          temp_state.add_transition(transit)
        end
        undetermined_states.delete(temp_state)
        determined_states.push(temp_state)
      end
      associate_finals(determined_states)
      Automaton.new(
        determined_states, @alphabet.clone, tot_transits, new_begin_state)
    end

    private

# Associates finals for determined automaton
# from states of nondetermined automaton
    def associate_finals(stat)
      ret_val = []
      @states.each do |orig|
        if orig.is_final
          stat.each do |state|
            state.id.split(',').each do |id|
              if id == orig.id
                state.finalize
                ret_val.push(state)
                break 2
              end
            end
          end
        end
      end
      ret_val
    end

    def find_state(state_id, container, container2)
      str = ''
      state_id.split(' ').sort.each { |st| str += st }
      container.each do |state|
        state.id == state_id ? (return state) : nil
      end
      container2.each do |state|
        state.id == state_id ? (return state) : nil
      end
      NIL
    end

    def merge_state_names(states)
      arr = []
      states.each { |state| arr.push(state.id) }
      arr = arr.uniq.sort
      str = ''
      arr.each do |id|
        str += id + ','
      end
      str.byteslice(0, str.length - 1)
    end

    def resolve_state_on_stack(char)
      popped = @stack.pop
      arr = popped.get_next(char)
      arr.each do |item|
        @stack.push(item)
      end
      arr.size
    end

    def initialize(stat_arr, alph_arr, trans_arr, start)
      @states = stat_arr
      @alphabet = alph_arr
      @transitions = trans_arr
      @starting_state = start
    end

    # states must contain start and final states
    def self.validate_states(states, start, final)
      if states.include? start[0]
        final.each do |fin|
          states.include?(fin) ? nil : (return false)
        end
        return true
      end
      false
    end

    def self.validate_transitions(states, alphabet, transitions)
      transitions.each do |tr|
        trans = tr.split('-')
        if !((states.include? trans[0]) && (states.include? trans[2]) &&
              (alphabet.include? trans[1]))
          return false
        else
          # rubocop hates it :/
        end
      end
      true
    end

    def item_to_str(array)
      str = ''
      array.each do |item|
        str += item.to_s + ' '
      end
      str.byteslice(0, str.length - 1)
    end
  end
end
