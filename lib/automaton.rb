#z f - mnozina stavu
#a b - vstupni abeceda
#z-a-f f-b-f - prechod Q-T-Q ze stavu Q pres pismeno T do stavu Q
#z - Pocatecni stav
#f - mnozina koncovych stavu

require 'graphviz'
require_relative 'state.rb'
require_relative 'transition.rb'
module Nfa2Dfa
  class Automaton
  
    public
  
    def to_str
      ret_val = ""
      str = ""
      @states.each do |state|
        str += state.id + " "
      end
      ret_val += str.byteslice(0, str.length-1) + "\n"
      str = ""
      @alphabet.each do |a|
        str+= a + " "
      end
      ret_val += str.byteslice(0, str.length-1) + "\n"
      str = ""
      @transitions.each do |trans|
        str += trans.beginning_state.id + "-" + trans.alphabet + "-" + trans.ending_state.id + " "
      end
      ret_val += str.byteslice(0, str.length-1) + "\n"
      str = ""
      ret_val += @starting_state.id + "\n"
      @states.each do |state|
        if state.is_final == true
          str += state.id + " "
        end
      end
      ret_val += str.byteslice(0, str.length-1)
      ret_val
    end
  
    def to_graph(path)
      g = GraphViz.new( :G, :type => :digraph)
      @states.each do |state|
        #puts state.id
        state.to_graph_node(g)
      end
      g.each_node() do |name, node|
        # puts name
      end
      @transitions.each do |trans|
        trans.to_graph_transition(g)
      end
      g.each_edge do |ed|
        #puts ed.node_one + " " + ed.node_two
      end
      g.output( :png => path )
    end
  
    def self.init(path)
      #nacteni ze souboru
      if File.file?(path)
        data_arr = Array.new
        index = 0
        File.open(path).each_line do |line|
          data_arr[index] = line
          index = index + 1
        end
        if validate(data_arr)
          get_valid_input(data_arr)
        else
          puts "Invalid input"
          NIL
        end
      else
        puts "Invalid input"
        NIL
      end
    end
  
    def self.validate(data_arr)
      parsed = []
      data_arr.each do |item|
        parsed.push item.split(' ')
      end
      validate_transitions(parsed[0], parsed[1], parsed[2]) && validate_states(parsed[0], parsed[3], parsed[4])
    end
  
    #format: pismeno<mezera>pismeno...
    def accepts?(data)
      formatted_input = data.split(' ')
      @stack = Array.new
      @stack.push(@starting_state)
      formatted_input.size == 0 ? @starting_state.is_final : recurs_accepts?(formatted_input, 0)
    end
  
    def deterministic?
      @states.each do |state|
        @alphabet.each do |char|
          if state.get_next(char).size > 1
            return false
          end
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
      if @stack.size != 0
        cnt = resolve_state_on_stack(data[index])
        index = index + 1
        if index == data.size
          cnt.times do
            if @stack.pop.is_final
              ret_val = true
            end
          end
        else
          return recurs_accepts?(data,index)
        end
      end
      ret_val
    end
  
    def self.get_valid_input(data_arr)
      states = Array.new
      fin = data_arr[4].split(' ')
      
      data_arr[0].split(' ').each do |wrd|
        states.push State.new(wrd)
      end
      fin.include?(states[0].id)
      states.each do |st|
        (fin.include? st.id) ? st.finalize : NIL
      end
      alphabet = Array.new
      data_arr[1].split(' ').each do |wrd|
        alphabet.insert(alphabet.size, wrd)
      end
      transitions = Array.new
      data_arr[2].split(' ').each do |wrd|
        trans = wrd.split('-')
        state1 = NIL
        state2 = NIL
        states.each do |item|
          trans[0] == item.id ? state1 = item : NIL
          trans[2] == item.id ? state2 = item : NIL
          state1 != NIL && state2 != NIL ? break : NIL
        end
        transitions.insert(transitions.size, Transition.new(state1, trans[1], state2))
        state1.add_transition(transitions[transitions.size-1])
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
  
    def determine_prot
      #https://edux.fit.cvut.cz/courses/BI-AAG/_media/lectures/03/bi-aag-03-operace_s_automaty-4.pdf
      undetermined_states = Array.new
      determined_states = Array.new
      transits = Array.new
      tot_transits = Array.new
      curr_states = Array.new
      undetermined_states[0] = @starting_state.clone
      new_begin_state = undetermined_states[0]
      while(undetermined_states.size > 0)
        temp_state = undetermined_states[0]
        curr_states.clear
        transits.clear
        @alphabet.each do |char|
          t_states_by_char = temp_state.get_next(char)
          if t_states_by_char.size > 0
            state_id = merge_state_names(t_states_by_char)
            state = find_state(state_id, determined_states, undetermined_states)
            if state
              transits.push(Transition.new(temp_state, char, state))
              tot_transits.push(Transition.new(temp_state, char, state))
            else
              #Tvorba noveho statu
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
    
      determined_states
      @alphabet
      tot_transits
      new_begin_state
      finals = associate_finals(determined_states)
      Automaton.new(determined_states, @alphabet.clone, tot_transits, new_begin_state)
    end
  
    private
  
    def associate_finals(stat)
      ret_val = Array.new
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
      str = ""
      state_id.split(' ').sort.each do |st|
        str += st
      end
      # state_id = str.slice(0, str.size - 2)
      container.each do |state|
        if state.id == state_id
          return state
        end
      end
      container2.each do |state|
        if state.id == state_id
          return state
        end
      end
      NIL
    end
  
    def merge_state_names(states)
      arr = Array.new
      states.each do |state|
        arr.push(state.id)
      end
      arr = arr.uniq.sort
      last = arr.pop
      str = ""
      arr.each do |id|
        str += id + ","
      end
      str += last
      str
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
  
    def self.validate_states(states, start, final)
      if states.include? start[0]
        final.each do |fin|
          if !(states.include? fin)
            return false
          end
          return true
        end
        return false
      end
      return false
    end
  
    def self.validate_transitions(states, alphabet, transitions)
      transitions.each do |tr|
        trans = tr.split('-')
        ((states.include? trans[0]) && (states.include? trans[2]) && (alphabet.include? trans[1])) ? NIL : (return false)
      end
      true
    end
  end
end