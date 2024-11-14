module Check

import Message;
import IO;
import ParseTree;
import List;

extend Syntax;

// internal type to represent unknown 
syntax Type = "*unknown*";

// type environment maps question names to types
// (NB: it's not a map, because the form can contain errors!)
alias TEnv = lrel[str, Type];

// build a Type Environment (TEnv) for a questionnaire.
TEnv collect(Form f) = [ ];


/*
 * typeOf: compute the type of expressions
 */

// the fall back type is *unknown*
default Type typeOf(Expr _, TEnv env) = (Type)`*unknown*`;

// a reference has the type of its declaration
Type typeOf((Expr)`<Id x>`, TEnv env) = t
    when <"<x>", Type t> <- env;

/*
 * Checking forms
 */

set[Message] check(start[Form] form) = check(form.top);

set[Message] check(Form form) 
  = { *check(q, env) | Question q <- form.questions }
  + checkDuplicates(form)
  + checkCycles(form)
  when TEnv env := collect(form);

set[Message] checkCycles(Form form) {
    return {};
}

set[Message] checkDuplicates(Form form) {
    return {};
}

/*
 * Checking questions
 */

// by default, there are no errors or warnings
default set[Message] check(Question _, TEnv _) = {};


/*
 * Checking expressions
 */


// when the other cases fail, there are no errors
default set[Message] check(Expr _, TEnv env) = {};

set[Message] check(e:(Expr)`<Id x>`, TEnv env) = {error("undefined question", x.src)}
    when "<x>" notin env<0>;

set[Message] check((Expr)`(<Expr e>)`, TEnv env) = check(e, env);


void printTEnv(TEnv tenv) {
    for (<str x, Type t> <- tenv) {
        println("<x>: <t>");
    }
}
 
