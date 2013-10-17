= Ruby/nfa2dfa

== DESCRIPTION

Finite automaton determinizer as semestral project for MI-RUB on CVUT-FIT[fit.cvut.cz]

== SYNOPSIS

A basic example

  require 'graphviz'

  # Create a new graph
  g = GraphViz.new( :G, :type => :digraph )

  # Create two nodes
  hello = g.add_nodes( "Hello" )
  world = g.add_nodes( "World" )

  # Create an edge between the two nodes
  g.add_edges( hello, world )

  # Generate output image
  g.output( :png => "hello_world.png" )
  
The same but with a block

  require 'graphviz'

  GraphViz::new( :G, :type => :digraph ) { |g|
    g.world( :label => "World" ) << g.hello( :label => "Hello" )
  }.output( :png => "hello_world.png" )

Or with the DSL

  require 'graphviz/dsl'
  digraph :G do
    world[:label => "World"] << hello[:label => "Hello"]

    output :png => "hello_world.png"
  end

Create a graph from a file 

  require 'graphviz'

  # In this example, hello.dot is :
  #   digraph G {Hello->World;}

  GraphViz.parse( "hello.dot", :path => "/usr/local/bin" ) { |g|
    g.get_node("Hello") { |n|
      n[:label] = "Bonjour"
    }
    g.get_node("World") { |n|
      n[:label] = "Le Monde"
    }
  }.output(:png => "sample.png")

GraphML[http://graphml.graphdrawing.org/] support

  require 'graphviz/graphml'
  
  g = GraphViz::GraphML.new( "graphml/cluster.graphml" )
  g.graph.output( :path => "/usr/local/bin", :png => "#{$0}.png" )


== TOOLS

Ruby/GraphViz also includes :

* <tt>ruby2gv</tt>, a simple tool that allows you to create a dependency graph from a ruby script. Example : http://drp.ly/dShaZ

    ruby2gv -Tpng -oruby2gv.png ruby2gv

* <tt>gem2gv</tt>, a tool that allows you to create a dependency graph between gems. Example : http://drp.ly/dSj9Y

    gem2gv -Tpng -oruby-graphviz.png ruby-graphviz

* <tt>dot2ruby</tt>, a tool that allows you to create a ruby script from a graphviz script

    $ cat hello.dot
    digraph G {Hello->World;}
    
    $ dot2ruby hello.dot
    # This code was generated by dot2ruby.g
    
    require 'rubygems'
    require 'graphviz'
    graph_g = GraphViz.digraph( "G" ) { |graph_g|
      graph_g[:bb] = '0,0,70,108'
      node_hello = graph_g.add_nodes( "Hello", :height => '0.5', :label => '\N', :pos => '35,90', :width => '0.88889' )
      graph_g.add_edges( "Hello", "World", :pos => 'e,35,36.413 35,71.831 35,64.131 35,54.974 35,46.417' )
      node_world = graph_g.add_nodes( "World", :height => '0.5', :label => '\N', :pos => '35,18', :width => '0.97222' )
    }
    puts graph_g.output( :canon => String )

* <tt>git2gv</tt>, a tool that allows you to show your git commits : http://dl.dropbox.com/u/72629/ruby-graphviz-git.svg

* <tt>xml2gv</tt>, a tool that allows you to show a xml file as graph.


== INSTALLATION

  sudo gem install nfa2dfa

This gem uses gem Ruby-Graphviz[https://github.com/glejeune/Ruby-Graphviz].
Therefore you also need to install GraphViz[http://www.graphviz.org] 
