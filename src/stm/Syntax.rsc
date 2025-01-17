module stm::Syntax

extend lang::std::Layout;
extend lang::std::Id;


start syntax Machine 
 = "machine" Id name State* states;

syntax State
 = "state" Id name Trans* transitions "end";

syntax Trans
 = Id event "=\>" Id target;


// modeling declaring occurrences of names
alias Def = rel[str name, loc def];

// modeling use occurrences of names
alias Use = rel[loc use, str name];

alias UseDef = rel[loc use, loc def];

// the reference graph
alias RefGraph = tuple[
  Use uses, 
  Def defs, 
  UseDef useDef
]; 

RefGraph resolve(start [Machine] m) = resolve(m.top);

RefGraph resolve(Machine m){
    RefGraph ref = <{}, {}, {}>;

    for ( State s <- m.states){
        ref.defs += {<"<s.name>", s.name.src>};
    }

    for ( State s <- m.states, Trans t <- s.transitions){
        ref.uses += {<t.target.src, "<t.target>">};
    }

    ref.useDef = ref.uses o ref.defs;

    return ref;
}