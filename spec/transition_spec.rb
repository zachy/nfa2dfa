require 'rspec'
require 'spec_helper'
require_relative '../lib/transition.rb'

describe Nfa2Dfa::Transition do
  context 'should keep ' do
    state1 = State.new('1')
    state2 = State.new('2')
    state2.finalize
    subject { Transition.new(state1, 'a', state2) }

    it 'states' do
      subject.beginning_state.should eq state1
      subject.ending_state.should eq state2
    end

    it 'transition alphabet' do
      subject.alphabet.should eq 'a'
    end

    it 'correct types' do
      subject.beginning_state.class.should eq State
      subject.ending_state.class.should eq State
      subject.alphabet.class.should eq String
    end
  end
end
