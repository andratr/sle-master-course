module tutorial::Series2

import ParseTree;
import IO;
import String;


/*
 * Syntax definition
 * - define a grammar for JSON (https://json.org/)
 */
 
start syntax JSON
  = Object;

syntax Object
  = "{" {Element ","}* elements "}";

syntax Element
  = Key ":" Value;

syntax Key
  = String;
  
syntax Value
  = String
  | Number
  | Array
  | Object
  | Boolean
  | Null
  ;

syntax Null
  = "null";
  
syntax Boolean
  = "true"
  | "false"
  ;  
  
syntax Array
    = Array: "[" { Value ","}* values "]"
    ;
  
lexical String
  = [\"] ![\"]* [\"]; // slightly simplified
  
lexical Number
  = "-"? [0-9]+ ("." [0-9]+)? (("e" | "E") ("+" | "-")? [0-9]+)?;
// Fill in. Hint; think of the pattern for numbers in regular expressions. How do you accept a number in a regex?  

layout Whitespace = [\ \t\n]* !>> [\ \t\n];  
  
// import the module in the console
start[JSON] example() 
  = parse(#start[JSON], 
          "{
          '  \"age\": 42, 
          '  \"name\": \"Joe\",
          '  \"address\": {
          '     \"street\": \"Wallstreet\",
          '     \"number\": 102
          '  }
          '}");    
  

data NULL = null();

// use visit/deep match to find all element names
// - use concrete pattern matching
// - use "<x>" to convert a String x to str
set[str] propNames(Object obj) =
    { unquote("<k>") | /Key k <- obj.elements };

// define a recursive transformation mapping JSON to map[str,value] 
// - every Value constructor alternative needs a 'transformation' function
// - define a data type for representing null;

map[str, value] json2map(start[JSON] json) = json2map(json.top);

map[str, value] json2map((JSON)`<Object obj>`)  = json2map(obj);
map[str, value] json2map(Object obj) = 
    ( unquote("<k>") : json2value(v) | /Element e <- obj.elements, Key k := e[0], Value v := e[2] );


str unquote(str s) = s[1..-1];

value json2value((Value)`<String s>`) = unquote("<s>"); // This will transform the String literal to a value

value json2value((Value)`<Number n>`) = n;

// Transform Boolean to its corresponding true/false value
value json2value((Value)`true`) = true;
value json2value((Value)`false`) = false;

// Transform Null to null
value json2value((Value)`Null()`) = null;

// Transform Array to a list of values
value json2value((Value)`<Array a>`) = [json2value(v) | Value v <- a];

// Transform Object to a map of string to values
value json2value((Value)`Object(elements)`) = json2map((Object)`{elements}`);

// The other alternatives are missing. You need to add them.

default value json2value(Value v) { throw "No tranformation function for `<v>` defined"; }


test bool example2map() = json2map(example()) == (
  "age": 42,
  "name": "Joe",
  "address" : (
     "street" : "Wallstreet",
     "number" : 102
  )
);

