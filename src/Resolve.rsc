module Resolve

import Syntax;
import IO;
import ParseTree;

/*
 * Name resolution for QL
 */ 

// modeling declaring occurrences of names
alias Def = rel[str name, loc def];

// modeling use occurrences of names
alias Use = rel[loc use, str name];

alias UseDef = rel[loc use, loc def];

// the reference graph
alias RefGraph = tuple[
  Use uses, 
  Def defs, 
  UseDef useDef
]; 

RefGraph resolve(start[Form] f) {
  Use us = uses(f);
  Def ds = defs(f);
  UseDef ud = { <u, d> | <u, n> <- us, <n, d> <- ds };
  return <us, ds, ud>;
}



// keep track of which answer values are used where
Use uses(start[Form] f) {
  return { 
    <q.id.src, "<q.id>">
    | Question q <- f.top.questions,
      (simple_question(s, i, t) := q || computed_question(s, i, t, _) := q)
  };
}


// find where each value is defined in which question
Def defs(start[Form] f) {
  return { 
    <"<q.id>", q.id.src>
    | Question q <- f.top.questions,
      (simple_question(s, i, t) := q || computed_question(s, i, t, _) := q)
  };
}




void main() {
    
    // Parse the content into a parse tree
    value parseTree = parse(#start[Form], |project://sle-master-course/src/testForm.myql|);
    
    println(parseTree);

    // Implode the parse tree into an AST
    //Form ast = implode(#start[Form], parseTree);
    
    //println(ast);

    // Resolve the AST
    RefGraph refGraph = resolve(parseTree);
    
    // Print the reference graph
    println("Reference Graph:");
    println(refGraph);
}