module stm::Check


import stm::Syntax;
import Message;

/*

Errors
- Transition to undefined state
- Duplicate definition of state
- Unreachable state

Warnings
- Non-determinism
- Self transition

*/


set[Message] check(start [Machine] m, RefGraph refs){
    set [Message] msrg = {};
    for (<loc u, str x> <-refs.uses, !(<x, _> <- refs.defs)){
        msrg += {error("undefined state", u)};
    }


    
    return msrg;
    
}