
# Testing DSLs with DSLs

In this workshop we will introduce techniques for testing Domain-Specific Languages (DSLs): little languages dedicated to a particular problem domain.
We will introduce the aspects of a DSL that you want to test, and strategies to automate tests.
The workshop demonstrates these topics in the context of the [Rascal Language Workbench](https://www.rascal-mpl.org/).

Overview of the workshop:
- 60 minutes: introduction of Rascal, QL, and TestQL (a DSL for testing QL)
- 30 minutes: installation, setup, and start of exercises
- break
- 45 minutes: continue with exercises
- 45 minutes: introduce scriptless testing with TESTAR and how DSL invariants can inform TESTAR.

The exercises (see below) are meant to experience what can look like to test aspects of DSL, including the syntax, the type checker, and the dynamic semantics. The implementation in this project has bugs! So the goal is to find them by writing tests. Optionally, you can have a look at the Rascal source code of the various parts (the syntax definition, the evaluator, or the type checker) to see if you can spot them, and, even more optionally, try to fix them (in that case, please rerun the `main();` command in the terminal described below). 

### Preliminaries for the practical part

Please install [VS Code](https://code.visualstudio.com/) and then the [Rascal VS Code extension](https://marketplace.visualstudio.com/items?itemName=usethesource.rascalmpl) (you can also find Rascal in the extension browser).

Git clone [this](https://github.com/cwi-swat/testing-dsls-with-dsls) repository (_NB: don't rename the folder!_). Finally, go to the File menu of VS Code and select "Add Folder to workspace", navigate to where you've cloned the repo, and select that directory. 

The workshop project comes with pre-wired IDE support for the Questionnaire Language (QL). 
To enable this: open the file `IDE.rsc`, and press the link at the top of the file "Open in new Rascal Terminal".
Then issue the following command in the terminal: `main();` (followed by enter).

## QL: a DSL for Questionnaires

The workshop is based on a DSL for questionnaires, called QL. QL allows you to define simple forms with conditions and computed values.
A QL program consists of a form, containing questions. A question can be a normal question, or a computed question. A computed question has an associated expression which defines its value. Both kinds of questions have a prompt (to show to the user), an identifier (its name), and a type. The conditional construct comes in two variants if and if-else. A block construct using `{}` can be used to group questions.

Questions are enabled and disabled when different values are entered, depending on their conditional context.

A full type checker of QL detects:
- references to undefined questions
- duplicate question declarations with different types
- conditions that are not of the type boolean
- operands of invalid type to operators
- duplicate labels (warning)
- cyclic data and control dependencies

The language supports boolean, integer and string types.

Different data types in QL map to different (default) GUI widgets. For instance, boolean would be represented as checkboxes, integers as numeric sliders, and strings as text fields.

Here’s a simple questionnaire in QL from the domain of tax filing:
```
form "Tax office example" { 
  "Did you sell a house in 2010?" // the prompt of the question
    hasSoldHouse: boolean         // and its name and type
  "Did you buy a house in 2010?"
    hasBoughtHouse: boolean
  "Did you enter a loan?"
    hasMaintLoan: boolean
    
  if (hasSoldHouse) { // conditional block
    "What was the selling price?"
      sellingPrice: integer
    "Private debts for the sold house:"
      privateDebt: integer
    "Value residue:"
      valueResidue: integer =      // a computed question
        sellingPrice - privateDebt // has an expression 
  }
}
```

See the folder `examples/` for example QL programs. Opening a QL file will show links at the top for compiling, running, and testing QL programs. 
Running a questionnaire immediately opens a browser pane in VS Code. Compiling will result in an HTML file and Javascript file; opening
them in a browser will again execute the questionnaire (albeit with a slightly different layout).

If you have Python installed and a recent version of the Chrome Driver (in the PATH) you can randomly test a questionnaire by pressing the link "Run Testar". There's also a link to save the oracle (as Python code) that is used by TESTAR. 


## TestQL: a DSL for testing DSLs

TestQL is DSL for testing QL. In fact, it's an extension of the QL language (Rascal supports extensible syntax definition), so that tests can be expressed in a
human readable, declarative format. TestQL files end with the extension `testql`, and have IDE support enabled, just like QL: see the links at the top, and at
each test case, to respectively execute the whole test suite, or an individual test. There's also a link to show the test coverage of the test suite, showing how much of the syntax of the DSL has been covered by tests. 


## Exercises

If you look at `myql.testql`, you will see example test cases for inspiration. 

### Type checking

These tests are written using the `test ... <form>` notation, with embedded markers `$error` or `$warning` around expressions or questions. 

- test that the type checker issues a warning when the same prompt occurs with two questions with different names. 
- test that adding integers and booleans is rejected by the type checker
- test that the condition of if-then/if-then-else should be boolean
- test that a question cannot be redeclared with a different type

### Syntax and dynamic semantics

These tests are written using the `test ... with ... <form> = {...}` format. 

- test that minus is left associative
- test that `||` has weaker precedence than `&&`
- test that nested if-then-else without `{}` binds the inner `else` to the inner `if` (_tricky_).
 - test that disabled (invisible) questions are not changed even if given input

### Rendering









