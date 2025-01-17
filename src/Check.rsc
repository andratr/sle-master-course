module Check

import Message;
import IO;
import ParseTree;
import List;
import Resolve;

extend Syntax;

// internal type to represent
// build a Type Environment (TEnv) for a questionnaire.
alias TEnv = lrel[str, Type];


// Main collect function to collect environment info for all questions
TEnv collect(Form f) {
    TEnv env = [];  

    for (Question q <- f.questions) {
        Type questionType = typeOf(q.cond, env);  
        env = env + [<q.question, questionType>];  
        
        if (ifThen(_, block) := q) {
            for (Question q2 <- block.questions) {
                Type questionType2 = typeOf(q2.cond, env);
                env = env + [<q2.question, questionType2>];  
            }
        }

        if (ifThenElse(_, blockThen, blockElse) := q) {
            for (Question q2 <- blockThen.questions) {
                Type questionType2 = typeOf(q2.cond, env);
                env = env + [<q2.question, questionType2>]; 
            }

            for (Question q2 <- blockElse.questions) {
                Type questionType2 = typeOf(q2.cond, env);
                env = env + [<q2.question, questionType2>];  
            }
        }
    }

    return env; 
}


/*
 * typeOf: compute the type of expressions
 */

default Type typeOf(Expr _, TEnv env) = (Type)`*unknown*`;

Type typeOf((Expr)`<Id x>`, TEnv env) = t when <"<x>", Type t> <- env;

Type typeOf((Expr)`true`, TEnv env) = (Type)`boolean`;
Type typeOf((Expr)`false`, TEnv env) = (Type)`boolean`;
Type typeOf((Expr)`<Int i>`, TEnv env) = (Type)`integer`;
Type typeOf((Expr)`<Str s>`, TEnv env) = (Type)`string`;


//Other type checks
Type typeOf((Expr)`<Expr e1> + <Expr e2>`, TEnv env) {
    Type t1 = typeOf(e1, env);
    Type t2 = typeOf(e2, env);
    return (t1 == (Type)`integer` && t2 == (Type)`integer`) ? (Type)`integer` : (Type)`*unknown*`;
}

Type typeOf((Expr)`<Expr e1> - <Expr e2>`, TEnv env) {
    Type t1 = typeOf(e1, env);
    Type t2 = typeOf(e2, env);
    return (t1 == (Type)`integer` && t2 == (Type)`integer`) ? (Type)`integer` : (Type)`*unknown*`;
}

Type typeOf((Expr)`<Expr e1> * <Expr e2>`, TEnv env) {
    Type t1 = typeOf(e1, env);
    Type t2 = typeOf(e2, env);
    return (t1 == (Type)`integer` && t2 == (Type)`integer`) ? (Type)`integer` : (Type)`*unknown*`;
}

Type typeOf((Expr)`<Expr e1> / <Expr e2>`, TEnv env) {
    Type t1 = typeOf(e1, env);
    Type t2 = typeOf(e2, env);
    return (t1 == (Type)`integer` && t2 == (Type)`integer`) ? (Type)`integer` : (Type)`*unknown*`;
}

Type typeOf((Expr)`<Expr e1> \< <Expr e2>`, TEnv env) {
    Type t1 = typeOf(e1, env);
    Type t2 = typeOf(e2, env);
    return (t1 == (Type)`integer` && t2 == (Type)`integer`) ? (Type)`boolean` : (Type)`*unknown*`;
}

Type typeOf((Expr)`<Expr e1> \> <Expr e2>`, TEnv env) {
    Type t1 = typeOf(e1, env);
    Type t2 = typeOf(e2, env);
    return (t1 == (Type)`integer` && t2 == (Type)`integer`) ? (Type)`boolean` : (Type)`*unknown*`;
}

Type typeOf((Expr)`<Expr e1> \<= <Expr e2>`, TEnv env) {
    Type t1 = typeOf(e1, env);
    Type t2 = typeOf(e2, env);
    return (t1 == (Type)`integer` && t2 == (Type)`integer`) ? (Type)`boolean` : (Type)`*unknown*`;
}

Type typeOf((Expr)`<Expr e1> \>= <Expr e2>`, TEnv env) {
    Type t1 = typeOf(e1, env);
    Type t2 = typeOf(e2, env);
    return (t1 == (Type)`integer` && t2 == (Type)`integer`) ? (Type)`boolean` : (Type)`*unknown*`;
}

Type typeOf((Expr)`<Expr e1> == <Expr e2>`, TEnv env) {
    Type t1 = typeOf(e1, env);
    Type t2 = typeOf(e2, env);
    return (t1 == t2) ? (Type)`boolean` : (Type)`*unknown*`;
}

Type typeOf((Expr)`<Expr e1> != <Expr e2>`, TEnv env) {
    Type t1 = typeOf(e1, env);
    Type t2 = typeOf(e2, env);
    return (t1 == t2) ? (Type)`boolean` : (Type)`*unknown*`;
}

Type typeOf((Expr)`<Expr e1> && <Expr e2>`, TEnv env) {
    Type t1 = typeOf(e1, env);
    Type t2 = typeOf(e2, env);
    return (t1 == (Type)`boolean` && t2 == (Type)`boolean`) ? (Type)`boolean` : (Type)`*unknown*`;
}

Type typeOf((Expr)`<Expr e1> || <Expr e2>`, TEnv env) {
    Type t1 = typeOf(e1, env);
    Type t2 = typeOf(e2, env);
    return (t1 == (Type)`boolean` && t2 == (Type)`boolean`) ? (Type)`boolean` : (Type)`*unknown*`;
}

Type typeOf((Expr)`!<Expr e>`, TEnv env) {
    Type t = typeOf(e, env);
    return (t == (Type)`boolean`) ? (Type)`boolean` : (Type)`*unknown*`;
}



/*
 * Checking forms
 */

set[Message] check(start[Form] form) = check(form.top);

set[Message] check(Form form) 
  = { *check(q, env) | Question q <- form.questions }
  + checkDuplicates(form)
  + checkCycles(form)
  when TEnv env := collect(form);


set[Message] checkDuplicates(Form form) {
    set[Str] questionLabels = {}; 
    set[Message] msgs = {}; 

    for (Question q <- form.questions) {
        Str label = q.question;  

        if (label in questionLabels) {
            msgs += { error("duplicate question name", label.src) };
        } else {
            questionLabels += label;
        }

        // Check for questions inside "ifThen" or "ifThenElse" blocks
        if (ifThen(_, block) := q) {
            for (Question nestedQ <- block.questions) {
                Str nestedLabel = nestedQ.question;
                if (nestedLabel in questionLabels) {
                    msgs += { error("duplicate question name", nestedLabel.src) };
                } else {
                    questionLabels += nestedLabel;
                }
            }
        }

        if (ifThenElse(_, blockThen, blockElse) := q) {
            for (Question nestedQ <- blockThen.questions) {
                Str nestedLabel = nestedQ.question;
                if (nestedLabel in questionLabels) {
                    msgs += { error("duplicate question name", nestedLabel.src) };
                } else {
                    questionLabels += nestedLabel;
                }
            }
            for (Question nestedQ <- blockElse.questions) {
                Str nestedLabel = nestedQ.question;
                if (nestedLabel in questionLabels) {
                    msgs += { error("duplicate question name", nestedLabel.src) };
                } else {
                    questionLabels += nestedLabel;
                }
            }
        }
    }

    return msgs;
}



// Collects dependencies from a computed_question
set[str] collectDependencies(Question q) {
    return { "<id>" |
        computed_question(_, _, _, Expr e) := q,  // Pattern match for computed_question
        (Expr)`<Id id>` := e  // Match the expression to be an identifier
    };
}

// Checks for cycles in the question dependencies in a form
set[Message] checkCycles(Form form) {
    set[str] visited = {};  
    set[Message] msgs = {};  

    for (Question q <- form.questions) {
        set[str] deps = collectDependencies(q); 
        visited += deps;  

        msgs += { error("cycle detected in question dependencies", q.src) |
            deps & visited != {}  
        };
    }

    return msgs;  
}

// Checks if an expression refers to an undefined identifier in the reference graph
//set[Message] checkDependencies(Expr e, RefGraph refs) {
//    return { error("undefined reference", e.src) |
//        e == (Expr)`<Id x>`, 
//        not (<x, _> in refs.defs) 
//    };
//}

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

set[Message] check(e:(Expr)`<Id x>`, TEnv env) 
= {error("undefined question", x.src)}
    when "<x>" notin env<0>;

set[Message] check((Expr)`(<Expr e>)`, TEnv env) = check(e, env);

void printTEnv(TEnv tenv) {
    for (<str x, Type t> <- tenv) {
        println("<x>: <t>");
    }
}
 





// Type checks
set[Message] check((Expr)`<Expr e1> + <Expr e2>`, TEnv env) {
    Type t1 = typeOf(e1, env);
    Type t2 = typeOf(e2, env);
    return { 
        error("type mismatch in +", e1.src) | t1 != (Type)`integer`, t2 != (Type)`integer` 
    };
}

set[Message] check((Expr)`<Expr e1> - <Expr e2>`, TEnv env) {
    Type t1 = typeOf(e1, env);
    Type t2 = typeOf(e2, env);
    return { 
        error("type mismatch in -", e1.src) | t1 != (Type)`integer`, t2 != (Type)`integer` 
    };
}

set[Message] check((Expr)`<Expr e1> * <Expr e2>`, TEnv env) {
    Type t1 = typeOf(e1, env);
    Type t2 = typeOf(e2, env);
    return { 
        error("type mismatch in *", e1.src) | t1 != (Type)`integer`, t2 != (Type)`integer` 
    };
}

set[Message] check((Expr)`<Expr e1> / <Expr e2>`, TEnv env) {
    Type t1 = typeOf(e1, env);
    Type t2 = typeOf(e2, env);
    return { 
        error("type mismatch in /", e1.src) | t1 != (Type)`integer`, t2 != (Type)`integer` 
    };
}

set[Message] check((Expr)`<Expr e1> \< <Expr e2>`, TEnv env) {
    Type t1 = typeOf(e1, env);
    Type t2 = typeOf(e2, env);
    return { 
        error("type mismatch in \<", e1.src) | t1 != (Type)`integer`, t2 != (Type)`integer` 
    };
}

set[Message] check((Expr)`<Expr e1> \> <Expr e2>`, TEnv env) {
    Type t1 = typeOf(e1, env);
    Type t2 = typeOf(e2, env);
    return { 
        error("type mismatch in \>", e1.src) | t1 != (Type)`integer`, t2 != (Type)`integer` 
    };
}

set[Message] check((Expr)`<Expr e1> \<= <Expr e2>`, TEnv env) {
    Type t1 = typeOf(e1, env);
    Type t2 = typeOf(e2, env);
    return { 
        error("type mismatch in \<=", e1.src) | t1 != (Type)`integer`, t2 != (Type)`integer` 
    };
}

set[Message] check((Expr)`<Expr e1> \>= <Expr e2>`, TEnv env) {
    Type t1 = typeOf(e1, env);
    Type t2 = typeOf(e2, env);
    return { 
        error("type mismatch in \>=", e1.src) | t1 != (Type)`integer`, t2 != (Type)`integer` 
    };
}

set[Message] check((Expr)`<Expr e1> == <Expr e2>`, TEnv env) {
    Type t1 = typeOf(e1, env);
    Type t2 = typeOf(e2, env);
    return { 
        error("type mismatch in ==", e1.src) | t1 != t2 
    };
}

set[Message] check((Expr)`<Expr e1> != <Expr e2>`, TEnv env) {
    Type t1 = typeOf(e1, env);
    Type t2 = typeOf(e2, env);
    return { 
        error("type mismatch in !=", e1.src) | t1 != t2 
    };
}

set[Message] check((Expr)`<Expr e1> && <Expr e2>`, TEnv env) {
    Type t1 = typeOf(e1, env);
    Type t2 = typeOf(e2, env);
    return { 
        error("type mismatch in &&", e1.src) | t1 != (Type)`boolean`, t2 != (Type)`boolean` 
    };
}

set[Message] check((Expr)`<Expr e1> || <Expr e2>`, TEnv env) {
    Type t1 = typeOf(e1, env);
    Type t2 = typeOf(e2, env);
    return { 
        error("type mismatch in ||", e1.src) | t1 != (Type)`boolean`, t2 != (Type)`boolean` 
    };
}

set[Message] check((Expr)`!<Expr e>`, TEnv env) {
    Type t = typeOf(e, env);
    return { 
        error("type mismatch in !", e.src) | t != (Type)`boolean` 
    };
}
