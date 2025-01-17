module App

import salix::HTML;
import salix::App;
import salix::Core;
import salix::Index;

import Eval;
import Syntax;

import String;
import IO;
import ParseTree;

// The salix application model is a tuple
// containing the questionnaire and its current run-time state (env).
alias Model = tuple[start[Form] form, VEnv env];

App[Model] runQL(start[Form] ql) = webApp(qlApp(ql), |project://sle-master-course/src|);

SalixApp[Model] qlApp(start[Form] ql, str id="root") 
  = makeApp(id, 
        Model() { return <ql, initialEnv(ql)>; }, 
        withIndex("<ql.top.title>"[1..-1], id, view, css=["https://cdn.simplecss.org/simple.min.css"]), 
        update);


// The salix Msg type defines the application events.
data Msg
  = updateInt(str name, str n)
  | updateBool(str name, bool b)
  | updateStr(str name, str s)
  ;

// We map messages to Input values 
// to be able to reuse the interpreter defined in Eval.
Input msg2input(updateInt(str q, str n)) = user(q, vint(toInt(n)));
Input msg2input(updateBool(str q, bool b)) = user(q, vbool(b));
Input msg2input(updateStr(str q, str s)) = user(q, vstr(s));

// The Salix model update function simply evaluates the user input
// to obtain the new state. 
Model update(Msg msg, Model model) = model[env=eval(model.form, msg2input(msg), model.env)];

// Salix view rendering works by "drawing" on an implicit HTML canvas.
// Look at the Salix demo folder to learn how html elements are drawn, and how element nesting is achieved with
// nesting of void-closures.
// Main view function to render the entire questionnaire
void view(Model model) {
    h3("<model.form.top.title>"[1..-1]); // Render the title of the form

    div(() {
        for (Question q <- (model.form.questions)) {
            viewQuestion(q, model);
        }
    });
}

// Render individual questions based on their type
void viewQuestion(Question q, Model model) {
  switch (q) {
    case simple_question(Str label, Id id, Type t):
      div(() {
        "<label>";
        switch(t) {
          case (Type)`integer`:
            input(<"type", "number", "id", id, "value", \value("<model.env["<id>"].n>"), "onInput", updateInt("<id>", "<model.env["<id>"].n>")>);
          case (Type)`string`:
            input(<"type", "text", "id", id, "value", \value("<model.env["<id>"].s>"), "onInput", updateStr("<id>", "<model.env["<id>"].n>")>);
    //      case (Type)`boolean`:
    //        input(<"type", "checkbox", "id", id, "checked", model.env[id].b ? "checked" : "", "onChange", updateBool("<id>", "<model.env["<id>"].n>")>);
        }
      });

//`onInput(partial(updateStr, nameOfQuestion))`. 

    case computed_question(Str label, Id id, Type t, Expr v):
      div(() {
        "<label>";
        switch(t) {
          case (Type)`integer`:
            input(<"type", "number", "id", id, "value", \value("<model.env["<id>"].n>"), "disabled", "true">);
          case (Type)`string`:
            input(<"type", "text", "id", id, "value", \value("<model.env["<id>"].s>"), "disabled", "true">);
        //  case (Type)`boolean`:
        //    input(<"type", "checkbox", "id", id, "checked", model.env[id].b ? "checked" : "", "disabled", "true">);
        }
      });

    case block_question(Question* questions):
      div(() {
        for (Question q <- questions) {
          viewQuestion(q, model);
        }
      });

    case ifThenElse(Expr cond, Question thenQ, Question elseQ):
      if (eval(cond, model.env) == vbool(true)) {
        viewQuestion(thenQ, model);
      } else {
        viewQuestion(elseQ, model);
      }
  }
}


void main(){
    str fileContent = readFile(|project://sle-master-course/src/testForm.myql|);
    
    value parseTree = parse(#start[Form], fileContent);
    
    println(parseTree);

    runQL(parseTree);

}