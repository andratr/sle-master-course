module Visualize

import vis::Graphs;
import Syntax;
import Content;


// Identity of a node
alias DepId = tuple[Id name, loc location];

alias DepGraph = lrel[DepId from, str kind, DepId to];


Content visualizeDeps(start[Form] form) = 
    graph(form2deps(form), 
        \layout=defaultCoseLayout(), 
        nodeLabeler=str (DepId d) { return "<d.name>"; }, 
        nodeLinker=loc (DepId d) { return d.location; });


DepGraph form2deps(Form f) = form2deps(f.top);

// extra control/data dependencies from a form
// use the kind field in DepGraph to indicate whether it's a data dependency or a control dependency.
DepGraph form2deps(Form f) = [];