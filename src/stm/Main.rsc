module stm::Main


import ParseTree;
import stm::Syntax;
// import Check;

import util::LanguageServer;
import util::Reflective;
import Message;

set[LanguageService] myLanguageContributor() = {
    parser(Tree (str input, loc src) {
        return parse(#start[Machine], input, src);
    })
    // ,
    // summarizer(mySummarizer
    //     , providesDocumentation = false
    //     , providesDefinitions = true
    //     , providesReferences = false
    //     , providesImplementations = false)
};

// Summary mySummarizer(loc origin, start[Machine] input) {
//   RefGraph g = resolve(input);
//   set[Message] msgs = check(input);
//   rel[loc, Message] msgMap = {< m.at, m> | Message m <- msgs };  
//   return summary(origin, messages = msgMap, definitions = g.useDef);
// }

void main() {
    registerLanguage(
        language(
            pathConfig(srcs = [|std:///|, |project://sle-master-course/src|]),
            "State machine",
            "stm",
            "IDE",
            "myLanguageContributor"
        )
    );
}
