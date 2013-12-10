require File.expand_path('../lib/version.rb', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'nfa2dfa'
  s.version     = Nfa2Dfa::VERSION
  s.date        = '2013-10-28'
  s.summary     = "MI-RUB semestral"
  s.description = "Finite automaton determinizer"
  s.executables	= "nfa2dfa"
  s.authors     = ["Martin Zachov"]
  s.email       = 'martin.zachov@gmail.com'
  s.files       = `git ls-files`.split($/)
  s.test_files	= ["spec/automaton_spec.rb", "spec/state_spec.rb", "spec/transition_spec.rb"]
  s.homepage    = 'http://fit.cvut.cz'
  s.license     = 'GNU GPL'
  s.add_dependency "ruby-graphviz"
  s.add_dependency "commander"
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  s.requirements << 'graphviz'
end