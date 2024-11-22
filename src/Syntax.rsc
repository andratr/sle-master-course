module Syntax

// Import the necessary Rascal libraries
extend lang::std::Layout;
extend lang::std::Id;

// Define the starting syntax for the form structure
start syntax Form 
  = form: "form" Str title "{" Question* questions "}";

// Define lexical rules for strings, booleans, integers, and identifiers
lexical Str = "\"" ([^\"])* "\"";
lexical Bool = "true" | "false";
lexical Int = [0-9]+;
lexical Id = [a-zA-Z_][a-zA-Z0-9_]*; // Valid identifier names

// Define types: Bool, Int, Str
syntax Type = Bool | Int | Str;

// Define the Question structure (answerable, computed, block, if-then-else)
syntax Question
  = answerable: "question" Str prompt Type
  | computed: "computed" Expr calculation
  | block: "block" "{" Question* subQuestions "}"
  | ifThenElse: "if" "(" Expr cond ")" Question then () !>> "else" Question else ();

// Define expressions with operators and literals
syntax Expr
  = var: Id name 
  | boolTrue: "true" 
  | boolFalse: "false" 
  | binOpAdd: Expr "+" Expr
  | binOpSub: Expr "-" Expr
  | binOpMul: Expr "*" Expr
  | binOpDiv: Expr "/" Expr
  | comparisonEQ: Expr "==" Expr;
