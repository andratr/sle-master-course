module Flatten

import Syntax;

// Flatten a form by traversing its questions and reducing the hierarchy
list[Question] flatten(Form f) = flatten(toList(f.questions), (Expr)`true`);

list[Question] flatten(list[Question] qs, Expr currentCondition) =
  [*flattenQuestion(q, currentCondition) | q <- qs];

list[Question] flattenQuestion(Question q, Expr currentCondition) {
  switch (q) {
    case ifThen(cond, Question inner_questions):
      return flatten(inner_questions.questions, (Expr)`<Expr currentCondition> && <Expr cond>`);
    case ifThenElse(cond, Question inner_questions, Questions else_questions):
      return flatten([q | q <- inner_questions], (Expr)`<Expr currentCondition> && <Expr cond>`)
        + flatten([q | q <- else_questions], (Expr)`<Expr currentCondition> && !(<Expr cond>)`);
    default:
      return [];
  }
}

// Unflatten the list of questions back into a form structure for validation or reuse
start[Form] unflatten(list[Question] qs, start[Form] org) {
  Str title = org.title;
  Form f = (Form)`form <Str title> {}`;
  for (Question q <- qs, (Form)`form <Str t> {<Question* qqs>}` := f) {
    f = (Form)`form <Str t> {
                '  <Question* qqs>
                '  <Question q>
                '}`;
  }
  return org[top=f];
}
