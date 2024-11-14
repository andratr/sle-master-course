module Eval

import Syntax;

import ParseTree;
import IO;

/*
 * Big-step semantics for QL
 */
 
// NB: Eval assumes the form is type- and name-correct.

// Semantic domain for expressions (values)
data Value
  = vint(int n)
  | vbool(bool b)
  | vstr(str s)
  ;

// The value environment, mapping question names to values.
alias VEnv = map[str name, Value \value];

// Modeling user input
data Input = user(str question, Value \value);
  

Value type2default((Type)`integer`) = vint(0);
Value type2default((Type)`string`) = vstr("");
Value type2default((Type)`boolean`) = vbool(false);


// produce an environment which for each question has a default value
// using the function type2default function defined above.
// observe how visit traverses the form and match on normal questions and computed questions.
VEnv initialEnv(start[Form] f) = initialEnv(f.top);

VEnv initialEnv(Form f) {
  return ();
}

// Expression evaluation (complete for all expressions)

Value eval((Expr)`<Id x>`, VEnv venv) = venv["<x>"];

VEnv eval(start[Form] f, Input inp, VEnv venv) = eval(f.top, inp, venv);

// Because of out-of-order use and declaration of questions
// we use the solve primitive in Rascal to find the fixpoint of venv.
VEnv eval(Form f, Input inp, VEnv venv) {
  return solve (venv) {
    venv = evalOnce(f, inp, venv);
  }
}

// evaluate the questionnaire in one round 
VEnv evalOnce(Form f, Input inp, VEnv venv)
  = ( venv | eval(q, inp, it) | Question q <- f.questions );


VEnv eval(Question q, Input inp, VEnv venv) {
  return ();
}

/*
 * Rendering UIs: use questions as widgets
 */

list[Question] render(start[Form] form, VEnv venv) = render(form.top, venv);

list[Question] render(Form form, VEnv venv) = [];

Expr value2expr(vbool(bool b)) = [Expr]"<b>";
Expr value2expr(vstr(str s)) = [Expr]"\"<s>\"";
Expr value2expr(vint(int i)) = [Expr]"<i>";

void printUI(list[Question] ui) {
  for (Question q <- ui) {
    println(q);
  }
}


void evalSnippets() {
  start[Form] pt = parse(#start[Form], |project://testing-dsls-with-dsls/examples/tax.myql|);

  env = initialEnv(pt);
  env2 = eval(pt, user("hasSoldHouse", vbool(true)), env);
  env3 = eval(pt, user("sellingPrice", vint(1000)), env2);
  env4 = eval(pt, user("privateDebt", vint(500)), env3);

  for (Input u <- [user("hasSoldHouse", vbool(true)), user("sellingPrice", vint(1000)), user("privateDebt", vint(500))]) {
    env = eval(pt, u, env);
    println(env);
  }
}