module PartialEvaluation

import Syntax;
import Eval;
import Flatten;

 /*
  * Partial evaluation:
  *  evaluate a questionnaire to another questionnaire with partial knowledge 
  *  as represented by the VEnv argument.
  *   - if conditions evaluate to true or false eliminate if-constructs
  *   - if variables are in VEnv evaluate them to values
  *   - expressions with value operands should be evaluated 
  *  Use eval where needed. 
  */


start[Form] peval(start[Form] form, VEnv venv) = unflatten(peval(flatten(form), venv), form);

list[Question] peval(list[Question] qs, VEnv venv) {
    return [];
} 


// NB: this function returns a list of questions
// so that if conditionals disappear you can return the empty list.
list[Question] peval(Question q, VEnv venv) {
    return [];
}



Expr peval(Expr e, VEnv venv) = e;

