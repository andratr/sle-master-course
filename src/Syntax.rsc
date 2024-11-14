module Syntax

extend lang::std::Layout;
extend lang::std::Id;

start syntax Form 
  = form: "form" Str title "{" Question* questions "}"; 

lexical Str = [\"]![\"]* [\"];

lexical Bool = "true" | "false";

lexical Int = ; 

syntax Type = ;


syntax Question 
  = ifThen: "if" "(" Expr cond ")" Question then () !>> "else" 
  ;


syntax Expr
  = var: Id name \ "true" \"false"
  ;

