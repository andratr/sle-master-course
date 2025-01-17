module Format

import util::SimpleBox;
import String;
import Syntax;

/*
 * Formatting: transforming QL forms to Box
 */

// Main entry point to format a Form into a string representation
str formatQL(start[Form] form) = format(form2box(form));

// Convert a Form into a Box structure
Box form2box(start[Form] form) = V(
  H("form ", "\"", form.title, "\"", " {"),
  I([question2box(q) | q <- form.questions]),
  "}"
);

// Convert a Question into a Box structure
Box question2box(Question q) {
  switch (q) {
    case ifThenElse(cond, inner_questions, else_questions):
      return V(
        H("if (", formatExpr(cond), ") {"),
        I([question2box(inner) | inner <- inner_questions]),
        "} else {",
        I([question2box(elseQ) | elseQ <- else_questions]),
        "}"
      );
    // add.. case simple_question, computed_question, block_question
    default:
      return H("// Unknown question type");
  }
}

// Convert a Type into a string representation
str formatType(Type t) {
  switch (t) {
    case Bool: return "boolean";
    case Int: return "int";
    case Str: return "string";
    default:
      return "// Unknown type";
  }
}

//str formatEnumValue(EnumValue v) = v.label + " " + v.id;

str formatExpr(Expr e) {
  switch (e) {
    case var(Id id): return "<id>";
    case (Expr)`true`: return "true";
    case (Expr)`false`: return "false";
    case (Expr)`<Int i>`: return "<i>";
    case (Expr)`<Str s>`: return "\"<s>\"";
    case parens(Expr inner): return "(" + formatExpr(inner) + ")";
    case lt(left, right): return formatExpr(left) + "\< " + formatExpr(right);
    case gt(left, right): return formatExpr(left) + " \> " + formatExpr(right);
    case le(left, right): return formatExpr(left) + " \<= " + formatExpr(right);
    case ge(left, right): return formatExpr(left) + " \>= " + formatExpr(right);
    case eq(left, right): return formatExpr(left) + " == " + formatExpr(right);
    case neq(left, right): return formatExpr(left) + " != " + formatExpr(right);
    case mul(left, right): return formatExpr(left) + " * " + formatExpr(right);
    default:
      return "// Unknown expression";
  }
}
