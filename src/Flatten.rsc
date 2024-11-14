module Flatten

import Syntax;

/* Normalization:
 *  wrt to the semantics of QL the following
 *     q0: "" int; 
 *     if (a) { 
 *        if (b) { 
 *          q1: "" int; 
 *        } 
 *        q2: "" int; 
 *      }
 *
 *  is equivalent to
 *     if (true) q0: "" int;
 *     if (true && a && b) q1: "" int;
 *     if (true && a) q2: "" int;
 *
 * Write a transformation that performs this flattening transformation.
 *
 */
 
list[Question] flatten(start[Form] f) = flatten(f.top);

list[Question] flatten(Form f) = [];

// helper function to go back to a proper questionnaire term.
start[Form] unflatten(list[Question] qs, start[Form] org) {
    Str title = org.top.title;
    Form f = (Form)`form <Str title> {}`;
    for (Question q <- qs, (Form)`form <Str t> {<Question* qqs>}` := f) {
        f = (Form)`form <Str t> {
                  '  <Question* qqs>
                  '  <Question q>
                  '}`;
    }
    return org[top=f];
}
