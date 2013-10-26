# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'graphviz'
#require_relative 'automaton.rb'
require_relative 'nfa2dfa.rb'
# struktura souboru
#z f - mnozina stavu
#a b - vstupni abeceda
#z-a-f f-b-f - prechod Q-T-Q ze stavu Q pres pismeno T do stavu Q
#z - Pocatecni stav
#f - mnozina koncovych stavu
ARGV.each do |arg|
  input_mat = Nfa2Dfa::Automaton.init(arg)
  if input_mat != NIL
    #puts input_mat.to_str
    input_mat.to_graph(arg + ".png")
    if input_mat.deterministic? 
      puts "Is DKA"
    else
      puts "Is NKA, going to create DKA"
      puts ""
      output_mat = input_mat.determine
      #puts output_mat.to_str
      output_mat.to_graph(arg + "determined.png")
    end
  end
end

