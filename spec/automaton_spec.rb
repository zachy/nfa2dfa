require 'rspec'
require 'spec_helper'
require_relative '../lib/automaton.rb'

describe Nfa2Dfa::Automaton do
  before(:each) do
    @file_path = "#{File.dirname(__FILE__)}/testdata/valid_input.automat"
    @file_path2 = "#{File.dirname(__FILE__)}/testdata/valid_input2.automat"
    @file_path3 = "#{File.dirname(__FILE__)}/testdata/valid_input3.automat"
  end
  context "initializes as" do
    it "valid automaton" do 
      mat = Automaton.init(@file_path)
      mat.should_not eq NIL
      mat.class.should eq Nfa2Dfa::Automaton
    end
    it "invalid automaton, when there is invalid input" do 
      mat = Automaton.init("#{File.dirname(__FILE__)}/testdata/invalid_input.automat")
      mat.should eq NIL
    end
  end
  it "should be exportable in same format by method 'to_str'" do 
    valid_str = "z f\na b\nz-a-f f-b-f\nz\nf"
    mat = Automaton.init(@file_path)
    mat.to_str.should eq valid_str
  end
  
  context "accepts method resolves" do
    subject { Automaton.init(@file_path) }
    it "valid words" do
      (subject.accepts? "a b").should eq true
      (subject.accepts? "a").should eq true
      (subject.accepts? "a b b b").should eq true
      (subject.accepts? "a b b").should eq true
    end
    
    it "invalid words" do
      (subject.accepts? "").should eq false
      (subject.accepts? "a a").should eq false
      (subject.accepts? "a a ").should eq false
      (subject.accepts? "a b a").should eq false
    end
  end
  
  it "should be able to check if automat is deterministic" do
    Automaton.init(@file_path).deterministic?.should eq true
    Automaton.init(@file_path2).deterministic?.should eq false
  end
  
  context "can create deterministic automaton" do
    it "returns Automaton class" do
      mat1 = Automaton.init(@file_path)
      mat2 = Automaton.init(@file_path2)
      mat3 = Automaton.init(@file_path3)
      mat1.determine.class.should eq Nfa2Dfa::Automaton
      mat2.determine.class.should eq Nfa2Dfa::Automaton
      mat3.determine.class.should eq Nfa2Dfa::Automaton
    end
    it "returns same instance of Automaton when already deterministic" do
      mat1 = Automaton.init(@file_path)
      mat1det = mat1.determine
      mat1.should eq mat1det
    end
    it "returns deterministic automaton" do
      mat2 = Automaton.init(@file_path2)
      mat2det = mat2.determine
      mat2det.deterministic?.should eq true
    end
    
    it "which can accept same words" do
      mat2 = Automaton.init(@file_path2)
      mat2det = mat2.determine
      word = ""
      (mat2.accepts? word).should eq mat2det.accepts? word
      (mat2.accepts? word).should eq true
      word = "a a"
      (mat2.accepts? word).should eq mat2det.accepts? word
      (mat2.accepts? word).should eq true
      word = "a b"
      (mat2.accepts? word).should eq mat2det.accepts? word
      (mat2.accepts? word).should eq true
      word = "a c"
      (mat2.accepts? word).should eq mat2det.accepts? word
      (mat2.accepts? word).should eq true
      word = "a c c"
      (mat2.accepts? word).should eq mat2det.accepts? word
      (mat2.accepts? word).should eq true
      word = "a c c a"
      (mat2.accepts? word).should eq mat2det.accepts? word
      (mat2.accepts? word).should eq true
      word = "a c c a c a"
      (mat2.accepts? word).should eq mat2det.accepts? word
      (mat2.accepts? word).should eq true
      word = "a c c a c a a b"
      (mat2.accepts? word).should eq mat2det.accepts? word
      (mat2.accepts? word).should eq true
      word = "c a b c a b c"
      (mat2.accepts? word).should eq mat2det.accepts? word
      (mat2.accepts? word).should eq true
      word = "a c c b c"
      (mat2.accepts? word).should eq mat2det.accepts? word
      (mat2.accepts? word).should eq true
    end
    
    it "which rejects same words" do 
      mat2 = Automaton.init(@file_path3)
      mat2det = mat2.determine
      word = "0"
      (mat2.accepts? word).should eq mat2det.accepts? word
      (mat2.accepts? word).should eq false
      word = "1"
      (mat2.accepts? word).should eq mat2det.accepts? word
      (mat2.accepts? word).should eq false
      word = "0 1"
      (mat2.accepts? word).should eq mat2det.accepts? word
      (mat2.accepts? word).should eq false
      word = "1 0"
      (mat2.accepts? word).should eq mat2det.accepts? word
      (mat2.accepts? word).should eq false
      word = "1 1 1 1 0"
      (mat2.accepts? word).should eq mat2det.accepts? word
      (mat2.accepts? word).should eq false
      word = "0 0 0 0 1"
      (mat2.accepts? word).should eq mat2det.accepts? word
      (mat2.accepts? word).should eq false
    end
    
    it "should have method for exporting as GraphViz 'to_graph'" do
      mat = Automaton.init(@file_path2)
      expect(mat.methods.include?(:to_graph)).to be true
    end
  end
end

