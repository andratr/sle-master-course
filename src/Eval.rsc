module Eval

import Syntax;
import ParseTree;
import IO;
import String;

/*
 * Big-step semantics for QL
 */
 
// NB: Eval assumes the form is type- and name-correct.

// Semantic domain for expressions (values)
data Value
  = vint(int n)
  | vbool(bool b)
  | vstr(str s);

// The value environment, mapping question names to values.
alias VEnv = map[str, Value];

// Modeling user input
data Input = user(str question, Value \value);

// Default values for each type
Value type2default((Type)`integer`) = vint(0);
Value type2default((Type)`string`) = vstr("");
Value type2default((Type)`boolean`) = vbool(false);


// Initialize the environment with default values for each question
VEnv initialEnv(start[Form] f) = initialEnv(f.top);

// Initialize the environment with default values based on the form's questions
VEnv initialEnv(Form f) {
    VEnv venv = ();

    for (Question q <- f.questions) {
        switch (q) {
            case (Question)`<Str label> <Id id> : <Type t>`:
                venv["<id>"] = type2default(t);

            case (Question)`<Str label> <Id id> : <Type t> = <Expr e>`:
                venv["<id>"] = type2default(t);
        }
    }

    return eval(f, user("", vint(0)), venv);
}


// Evaluate expressions in the context of a VEnv
Value eval(Expr e, VEnv venv) {
  switch (e) {
    case (Expr)`<Id id>`: 
      return venv["<id>"];  

    case (Expr)`<Int n>`: 
      return vint(toInt("<n>"));  

    case (Expr)`<Bool b>`: 
      return vbool("<b>" == "true");  

    case (Expr)`<Str s>`: 
      return vstr("<s>"); 

    // Operations on expressions
    case (Expr)`<Expr lhs> + <Expr rhs>`: {  
      Value left = eval(lhs, venv);
      Value right = eval(rhs, venv);
      
      if (vint(int l) := left) {  
        if (vint(int r) := right) {  
          return vint(l + r);  // Add the integers
        }
        else {
          throw "Type mismatch in addition (right operand is not an integer)";
        }
      }
      else {
        throw "Left operand is not an integer";
      }
    }

    case (Expr)`<Expr lhs> - <Expr rhs>`: {  
      Value left = eval(lhs, venv);
      Value right = eval(rhs, venv);

      if (vint(int l) := left) {
        if (vint(int r) := right) {
          return vint(l - r);  // Subtract the integers
        }
        else {
          throw "Type mismatch in subtraction (right operand is not an integer)";
        }
      }
      else {
        throw "Left operand is not an integer";
      }
    }

    case (Expr)`<Expr lhs> * <Expr rhs>`: {
      Value left = eval(lhs, venv);
      Value right = eval(rhs, venv);

      if (vint(int l) := left) {
        if (vint(int r) := right) {
          return vint(l * r);  // Multiply the integers
        }
        else {
          throw "Type mismatch in multiplication (right operand is not an integer)";
        }
      }
      else {
        throw "Left operand is not an integer";
      }
    }

    case (Expr)`<Expr lhs> / <Expr rhs>`: {
      Value left = eval(lhs, venv);
      Value right = eval(rhs, venv);

      if (vint(int l) := left) {
        if (vint(int r) := right) {
          // Handle division by zero
          if (r != 0) {
            return vint(l / r);  // Divide the integers
          } else {
            throw "Division by zero error";
          }
        }
        else {
          throw "Type mismatch in division (right operand is not an integer)";
        }
      }
      else {
        throw "Left operand is not an integer";
      }
    }

    case (Expr)`<Expr lhs> && <Expr rhs>`: {
      Value left = eval(lhs, venv);
      Value right = eval(rhs, venv);

      if (vbool(bool l) := left) {
        if (vbool(bool r) := right) {
          return vbool(l && r);  // Perform boolean AND
        }
        else {
          throw "Type mismatch in AND (right operand is not a boolean)";
        }
      }
      else {
        throw "Left operand is not a boolean";
      }
    }

    case (Expr)`<Expr lhs> || <Expr rhs>`: {
      Value left = eval(lhs, venv);
      Value right = eval(rhs, venv);

      if (vbool(bool l) := left) {
        if (vbool(bool r) := right) {
          return vbool(l || r);  // Perform boolean OR
        }
        else {
          throw "Type mismatch in OR (right operand is not a boolean)";
        }
      }
      else {
        throw "Left operand is not a boolean";
      }
    }

    case (Expr)`<Expr lhs> \> <Expr rhs>`: {
      Value left = eval(lhs, venv);
      Value right = eval(rhs, venv);

      if (vint(int l) := left) {
        if (vint(int r) := right) {
          return vbool(l > r);  // Compare if left is greater than right
        }
        else {
          throw "Type mismatch in greater-than comparison (right operand is not an integer)";
        }
      }
      else {
        throw "Left operand is not an integer";
      }
    }

    case (Expr)`<Expr lhs> \< <Expr rhs>`: {
      Value left = eval(lhs, venv);
      Value right = eval(rhs, venv);

      if (vint(int l) := left) {
        if (vint(int r) := right) {
          return vbool(l < r);  // Compare if left is less than right
        }
        else {
          throw "Type mismatch in less-than comparison (right operand is not an integer)";
        }
      }
      else {
        throw "Left operand is not an integer";
      }
    }

    case (Expr)`<Expr lhs> == <Expr rhs>`: {
      Value left = eval(lhs, venv);
      Value right = eval(rhs, venv);
      
      return vbool(left == right);  // Check if both sides are equal
    }

    case (Expr)`<Expr lhs> != <Expr rhs>`: {
      Value left = eval(lhs, venv);
      Value right = eval(rhs, venv);

      return vbool(left != right);  // Check if both sides are not equal
    }

    case (Expr)`<Expr lhs> \<= <Expr rhs>`: {
      Value left = eval(lhs, venv);
      Value right = eval(rhs, venv);

      if (vint(int l) := left) {
        if (vint(int r) := right) {
          return vbool(l <= r);  // Compare if left is less than or equal to right
        }
        else {
          throw "Type mismatch in less-than-or-equal comparison (right operand is not an integer)";
        }
      }
      else {
        throw "Left operand is not an integer";
      }
    }

    case (Expr)`<Expr lhs> \>= <Expr rhs>`: {
      Value left = eval(lhs, venv);
      Value right = eval(rhs, venv);

      if (vint(int l) := left) {
        if (vint(int r) := right) {
          return vbool(l >= r);  // Compare if left is greater than or equal to right
        }
        else {
          throw "Type mismatch in greater-than-or-equal comparison (right operand is not an integer)";
        }
      }
      else {
        throw "Left operand is not an integer";
      }
    }

    case (Expr)`!<Expr e>`: {
      Value evalResult = eval(e, venv);

      if (vbool(bool b) := evalResult) {
        return vbool(!b);  // Negate the boolean value
      }
      else {
        throw "Operand for negation is not a boolean";
      }
    }

    // Parenthesized expression 
    case (Expr)`(<Expr e>)`: {
      return eval(e, venv);  // Evaluate the inner expression
    }

    default:
      throw "Unsupported expression type";
  }
}





// Evaluate the questionnaire in one round 
VEnv evalOnce(Form f, Input inp, VEnv venv)
  = ( venv | eval(q, inp, it) | Question q <- f.questions );

// Update the environment based on user input for a Form
VEnv eval(Form f, Input inp, VEnv venv) {
  return evalOnce(f, inp, venv);
}

// Update the environment based on user input for a Question
VEnv eval(Question q, Input inp, VEnv venv) {
  str questionLabel = inp.question;
  Value userValue = inp.\value;

  switch (q) {
    case (Question)`<Str label> <Id id> : <Type t>`: {
      if ("<label>" == questionLabel) {
        venv["<id>"] = userValue;
      }
      return venv;
    }

    case (Question)`<Str label> <Id id> : <Type t> = <Expr e>`: {
      if ("<label>" == questionLabel) {
        venv["<id>"] = userValue;
      } else {
        venv["<id>"] = eval(e, venv);
      }
      return venv;
    }
    default:
      return venv;
  }
}


// Rendering UIs: Use questions as widgets
list[Question] render(start[Form] form, VEnv venv) = render(form.top, venv);
list[Question] render(Form form, VEnv venv) = [ render(q, venv) | Question q <- form.questions ];
Question render(Question q, VEnv venv) {
  return q;
}

Expr value2expr(vbool(bool b)) = [Expr]"<b>";
Expr value2expr(vstr(str s)) = [Expr]"\"<s>\"";
Expr value2expr(vint(int i)) = [Expr]"<i>";

void printUI(list[Question] ui) {
  for (Question q <- ui) {
    println(q);
  }
}

// Test the evaluation logic with snippets
void evalSnippets() {
  println("parse form");
  start[Form] pt = parse(#start[Form], |project://sle-master-course/examples/tax.myql|);
  println(pt);

  println("initial environment");
  env = initialEnv(pt);
  print(env);
  
  println("Form Questions: ");
  for (Question q <- pt.top.questions) {
    println(q);
  }


  println("evaluating user input");

  env2 = eval(pt, user("hasSoldHouse", vbool(true)), env);
  env3 = eval(pt, user("sellingPrice", vint(1000)), env2);
  env4 = eval(pt, user("privateDebt", vint(500)), env3);

  println(env4);

  for (Input u <- [user("hasSoldHouse", vbool(true)), user("sellingPrice", vint(1000)), user("privateDebt", vint(500))]) {
    env = eval(pt, u, env);
    println(env);
  }
}
