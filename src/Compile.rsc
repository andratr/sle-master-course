module Compile

import Syntax;
import Eval;
import IO;
import ParseTree;
import String;

import lang::html::AST; // modeling HTML docs
import lang::html::IO; // reading/writing HTML

void compile(start[Form] form) {
  loc htmlFile = form.src[extension="html"];
  loc jsFile = form.src[extension="js"].top;

  // Generate HTML and JS from the form
  //str js = compile2js(form);
  HTMLElement htmlDom = compile2html(form);

  // Write the generated JS and HTML to files
  //writeFile(jsFile, js);
  writeHTMLFile(htmlFile, htmlDom, escapeMode=extendedMode());
}

HTMLElement compile2html(start[Form] form) {
  // Initialize a list to hold the HTML elements
  list[HTMLElement] elements = [];

  // Iterate through the form's questions to build the HTML structure
  for (question <- form.questions) {
    // Create a label and input for each question
    elements += [
      div([
          p([text("<question.id>")]),
          p([text("<question.\type>")])
      ])
    ];
  }


  // Return the full HTML document
  return html([
    lang::html::AST::head([
      title([text("<form.title>")])
    ]),
    body(elements)
  ]);
}




void saveFormAsHTML(loc file, start[Form] form) {
  HTMLElement dom = compile2html(form);
  writeHTMLFile(file, dom, escapeMode=extendedMode());
}

// void saveFormAsJS(loc file, start[Form] form) {
//  str js = compile2js(form);
//  writeFile(file, js);
//}

void main() {

  value parseTree = parse(#start[Form], |project://sle-master-course/src/testForm.myql|);

  saveFormAsHTML(|project://sle-master-course/src/testForm.html|, parseTree);
}
