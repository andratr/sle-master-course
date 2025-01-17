module util::UtilFunc

import Syntax;

 // Function to convert a list of questions to a set
set[Question] uniqueQuestions(Form form) {
    set[Question] questionsSet = {};
    for (Question q <- form.questions) {
        questionsSet := questionsSet + {q};  // Adds question if not already in set
    }
    return questionsSet;
}

// Function to convert a list[Question] to a grammar collection {Question*}
//{Question}* listToGrammarCollection(list[Question] questions) {
//    return {questions};
//}