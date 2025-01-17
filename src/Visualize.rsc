module Visualize

import vis::Graphs;
import Syntax;
import Content;

// Identity of a node
alias DepId = tuple[Id name, loc location];

// A dependency graph relation
alias DepGraph = lrel[DepId from, str kind, DepId to];

// Visualize the dependencies in a form
Content visualizeDeps(start[Form] form) = 
  graph(
    form2deps(form), 
    \layout=defaultCoseLayout(), 
    nodeLabeler=str (DepId d) { return "<d.name>"; }, 
    nodeLinker=loc (DepId d) { return d.location; }
  );

// Extract dependencies from a form
DepGraph form2deps(Form f) = form2deps(f.top);

// Helper to extract dependencies from a list of questions
DepGraph form2deps(list[Question] qs) = 
  (DepGraph)`{<DepGraph+ [form2deps(q) | q <- qs]>}`;

// Extract dependencies from a single question
DepGraph form2deps(Question q) {
  switch (q) {
    case simple_question(_, id, _, location):
      return {}; // Simple questions have no dependencies
    case computed_question(_, id, _, expr, location):
      return expr2deps(id, location, expr);
    case ifThenElse(_, cond, inner_questions, else_questions):
      //DepGraph condDeps = expr2deps( loc`unknown`, cond); // Condition dependencies
      DepGraph innerDeps = form2deps(inner_questions);
      DepGraph elseDeps = form2deps(else_questions);
      return condDeps + innerDeps + elseDeps;
    default:
      return {};
  }
}

// Extract dependencies from an expression
DepGraph expr2deps(Id id, loc location, Expr e) {
  switch (e) {
    case var(Id varName):
      return (DepGraph)`{<tuple[Id, loc](varName, location), "data", tuple[Id, loc](id, location)>}`;
    case binary_op(left, _, right):
      return expr2deps(id, location, left) + expr2deps(id, location, right);
    case logical(left, _, right):
      return expr2deps(id, location, left) + expr2deps(id, location, right);
    case parens(inner):
      return expr2deps(id, location, inner);
    default:
      return {};
  }
}
