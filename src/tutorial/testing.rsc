module tutorial::testing

import IO;
import String;

void main() {
    println("Hello, World!");
    tuple[str first, str last, int age] person = <"Jo", "Jones", 35>;
    println(person);
    println(person.first);
    println(person.last);
    println(person.age);
    list[tuple[str, int]] names_with_lengths = [<name, size(name)> | name <- ["Alice", "Bob", "Charlie"]];
    println(names_with_lengths);    


}

set[int] findEvens(list[int] numbers) {
  return { x | x <- numbers, x % 2 == 0 };
}


rel[int, int] pairNumbers(list[int] numbers) {
  return { <x, y> | x <- numbers, y <- numbers, x != y };
}


test bool testFindEvens() {
  return (findEvens([1, 2, 3, 4, 5, 6]) == {2, 4, 6});
}   

test bool testPairNumbers() {
  return (pairNumbers([1, 2, 3]) == {<1, 2>, <1, 3>, <2, 1>, <2, 3>, <3, 1>, <3, 2>});
}

