module Syntax

extend lang::std::Layout;
extend lang::std::Id;

start syntax Form 
  = form: "form" Str title "{" Question* questions "}"; 

lexical Str = [\"]![\"]* [\"];

lexical Bool = "true" | "false";

lexical Int = ; 

// boolean, integer, string
syntax Type = ;


// TODO: answerable question, computed question, block, if-then-else
syntax Question 
  = ifThen: "if" "(" Expr cond ")" Question then () !>> "else" 
  ;

// TODO: +, -, *, /, &&, ||, !, >, <, <=, >=, ==, !=, literals (bool, int, str)
// Think about disambiguation using priorities and associativity
// and use C/Java style precedence rules (look it up on the internet)
syntax Expr
  = var: Id name \ "true" \"false"
  ;

