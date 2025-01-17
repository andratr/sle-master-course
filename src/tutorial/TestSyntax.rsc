module tutorial::TestSyntax

import IO;
import ParseTree;
import String;
extend lang::std::Layout;
extend lang::std::Id;


lexical Term = [0-9]+;  

start syntax Expr
  = left add: Expr "+" Expr
  | con: Term;


// Imploding the parsed tree into an AST
data Expr 
  = add(Expr left, Expr right)
  | Term (int n);


data Term = Term(int n);       

//AExpr implode(start[Expr] e) = implode(e.top);

//AExpr implode(Expr e) {
//  switch (e) {
//    case (Expr)`<Term left> + <Term right>`:
//      return add(implode(left), implode(right));
//    case (Expr)`<Term t>`:
//      return ATerm(toInt("<t>"));
//    default: {
//      println(e);
//      throw "Unsupported expression type: ";
//       }
//  }
//}

//ATerm implode((Term)`<Term t>`) {
//  return ATerm(toInt("<t>"));
//}

void main() {
  str input = "5 + 5 + 5";
  
  println("test");

  Expr load(Tree t) = implode(#Expr, t);  

  Tree parseExpr(str txt) = parse(#Expr, txt);

  Tree example = parseExpr("2 + 3 + 4");

  println(example);

  Expr example2 = load(example);

  println(example2);


  //value parseTree = parse(#start[Expr], input);

  //println("Parse Tree:");
 // println(parseTree);

  //println("AST:");
  //value ast = implode(#start[Expr], parseTree);
  //println(ast); 
}