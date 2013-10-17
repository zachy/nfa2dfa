require 'rspec'
require 'spec_helper'
require_relative '../lib/state.rb'

describe Nfa2Dfa::State do
  before(:each) do
    @end_state = State.new("end")
    @end_state.to_starting_node
  end
  context "should keep " do
    subject { State.new("state") }

    it "basic data" do
      subject.id.should eq "state"
      subject.is_final.should eq false
    end

    it "transitions as private data" do
      expect { subject.transitions }.to raise_error NoMethodError
    end
    
    it "added transitions" do
      trans = Transition.new(subject, "jump", @end_state)
      transes = subject.add_transition(trans)
      transes.size.should eq 1
      transes[0].should eq trans
    end
    
    it "cleared transition array" do
      subject.clear_transitions.size.should eq 0
    end
  end
  
  it "should be able to be finalized" do
    state_a = State.new("a")
    state_a.is_final.should eq false
    state_a.finalize
    state_a.is_final.should eq true
    state_a.finalize
    state_a.is_final.should eq true
  end
  it "should be able to be starting node" do 
    state_a = State.new("a")
    state_a.is_starting.should eq false
    state_a.to_starting_node
    state_a.is_starting.should eq true
    state_a.to_starting_node
    state_a.is_starting.should eq true
  end
  
  context "gets correct next state" do 
    trans = []
    state_a = State.new("a")
    state_b = State.new("b")
    state_c = State.new("c")
    trans[0] = Transition.new(state_a, "0", state_b)
    trans[1] = Transition.new(state_b, "1", state_a)
    trans[2] = Transition.new(state_a, "0", state_a)
    trans[3] = Transition.new(state_c, "1", state_a)
    trans[4] = Transition.new(state_a, "0", state_c)
    state_a.add_transition(trans[0])
    state_a.add_transition(trans[2])
    state_a.add_transition(trans[4])
    state_b.add_transition(trans[1])
    state_c.add_transition(trans[3])
    
    it "array" do
      state_a.get_next("0").size.should eq 3
      state_a.get_next("1").size.should eq 0
    end
    
    it "in first step" do
      state_a.get_next("0")[0].should eq state_b
    end
    
    it "in second step" do
      state_a.get_next("0")[0].get_next("1")[0].should eq state_a
    end
  end
  
  context "while conversion from NFA to DFA" do
    trans = Array.new
    state_a = State.new("a")
    state_b = State.new("b")
    state_c = State.new("c")
    trans[0] = Transition.new(state_a, "0", state_b)
    trans[1] = Transition.new(state_b, "1", state_a)
    trans[2] = Transition.new(state_a, "0", state_a)
    trans[3] = Transition.new(state_c, "1", state_a)
    trans[4] = Transition.new(state_a, "0", state_c)
    
    subject { State.new("a,b") }
    it "should find correct transitions" do
      subject.associate_transitions(trans)
      subject.get_next("a").size.should eq 0
      subject.get_next("1").size.should eq 1
      subject.get_next("0").size.should eq 3
    end
  end
end

