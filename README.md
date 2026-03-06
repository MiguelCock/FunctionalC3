# Functional Programming Extensions for C3

This project brings functional programming capabilities to the C3 language using generics and aliases.
It extends C3 slices of any type (Type[]) with functional-style operations such as map, filter, for_each, contains and many others all written in pure C3.

## Usage

~~~ c
// import the module
import functional;

// instanciate the types you need
alias IterInt = Iter{int}

// use it
Iter{int} lter = {1, 2, 3, 4};

// iterate
lter
    .for_each(fn(x) => x * 2)
    .for_each(fn(x) => x * 4)
    .printn();
// [8, 16, 24, 32]

// check for condition
io::printn(lter.contains(fn(i) => i < 10));
// true

// clone lters
Iter{int} new_lter = lter
        .map(fn(x) => x * 2, tmem) // temporal allocator
        .for_each(fn(x) => x * 4);


// create a new filtered lter
Iter{int} lter_filtered = lter
        .filter(fn(num) => num > 23, tmem);
lter_filtered.printn();
// [24, 32]
~~~