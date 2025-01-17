module PartialEvaluation

import Syntax;
import Eval;
import Flatten;

/*
 * Partial evaluation:
 *  Evaluate a questionnaire with partial knowledge in VEnv.
 *  - Simplify conditions to eliminate branches where possible.
 *  - Replace variables with known values.
 *  - Evaluate expressions where operands are constants.
 */

// Main entry point for partial evaluation
start[Form] peval(start[Form] form, VEnv venv) = 
  unflatten(peval(flatten(form), venv), form);

// Partial evaluation for a list of questions
list[Question] peval(list[Question] qs, VEnv venv) = 
  [peval(q, venv) | q <- qs];

// Partial evaluation for a single question
//todo
list[Question] peval(Question q, VEnv venv) {
  switch (q) {
    case ifThenElse(_, cond, inner_questions, else_questions):
      Expr simplifiedCond = peval(cond, venv);
      if (bool b := eval(simplifiedCond, venv)) {
        return b ? peval(inner_questions, venv) : peval(else_questions, venv);
      }
      return [(Question)`if (${simplifiedCond}) {
        <Question* peval(inner_questions, venv)>
      } else {
        <Question* peval(else_questions, venv)>
      }`];
    case simple_question(_, id, _, _):
      return [q]; 
    case computed_question(_, id, _, expr, _):
      Expr simplifiedExpr = peval(expr, venv);
      if (Value v := eval(simplifiedExpr, venv)) {
        return [(Question)`<q.label> <id>: <q.type> = ${v} <q.location>`];
      }
      return [q]; 
    default:
      return [];
  }
}

// Simplify an expression
Expr peval(Expr e, VEnv venv) {
  switch (e) {
    case var(Id id): return id in venv ? (Expr)eval(e, venv) : e;
    case binary_op(left, op, right):
      Expr l = peval(left, venv), r = peval(right, venv);
      return evalBinary(l, r, op, venv);
    case logical(left, op, right):
      Expr l = peval(left, venv), r = peval(right, venv);
      return evalLogical(l, r, op, venv);
    default:
      return e; 
  }
}

// Evaluate a binary operation if both operands are values
Expr evalBinary(Expr left, Expr right, str op, VEnv venv) {
  if (Value l := eval(left, venv), Value r := eval(right, venv)) {
    return (Expr)eval((Expr)`<Value l> ${op} <Value r>`, venv);
  }
  return (Expr)`<Expr left> ${op} <Expr right>`;
}

// Evaluate a logical operation if both operands are boolean
Expr evalLogical(Expr left, Expr right, str op, VEnv venv) {
  if (Bool l := eval(left, venv), Bool r := eval(right, venv)) {
    return (Expr)(op == "&&" ? l && r : l || r);
  }
  return (Expr)`<Expr left> ${op} <Expr right>`;
}
