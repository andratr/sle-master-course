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

lexical Int = [\-]?[0-9]+ ; 

syntax Type = "boolean"|"integer"|"string"| enumtype: EnumType;

syntax EnumType 
  = "enum" "{" EnumValue* "}";

syntax EnumValue 
  = Str name;


syntax Question 
  = ifThen: "if" "(" Expr cond ")" Question then () !>> "else" 
  | ifThenElse: "if" "(" Expr cond ")" Question then
                "else" Question else 
  | block_question: "{" Question* questions "}"
  | simple_question: Str question Id id ":" Type type
  | computed_question: Str question Id id ":" Type type "=" Expr value
  ;

syntax Expr
  = var: Id name \ "true" \"false"
  | left parens: "(" Expr ")" 
  | str_val: Str val
  | int_val: Int val
  | bool_val: Bool val
  | not: "!" Expr
  > left 
      (
        lt: Expr "\<" Expr
      | gt: Expr "\>" Expr
      | le: Expr "\<=" Expr
      | ge: Expr "\>=" Expr
      | eq: Expr "==" Expr
      | neq: Expr "!=" Expr
      )
  > left
      (
        add: Expr "+" Expr
      | sub: Expr "-" Expr
      )
  > left 
      (
        mul: Expr "*" Expr
      | div: Expr "/" Expr
      )
  > left
      (
        and: Expr "&&" Expr
      | or: Expr "||" Expr
      )
;

  