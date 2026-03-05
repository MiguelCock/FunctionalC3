# Functional Programming Extensions for C3

This project brings functional programming capabilities to the C3 language using generics and aliases.
It extends C3 slices of any type (Type[]) with functional-style operations such as map, filter, for_each, contains and many others all written in pure C3.

### Example operations include:

- [x] for_each(fn) – Apply a function to each element (in place)
- [x] map(fn) – Create a new transformed lter
- [x] filter(fn) – Keep elements that satisfy a predicate
- [x] contains(fn) – Check if any element matches a predicate
- [x] find(fn) – Return the index of the first matching element
- [x] reverse() – Reverse the array in place
- [x] count(fn) – Count how many elements satisfy a predicate
- [x] sort(fn) – Sort the slice using a custom comparison function

## Usage

~~~ c
// import the module
import functional;

alias IterInt = Iter{int}
alias ApplyCallbackInt  = ApplyCallback {int};
alias ApplyCallbackBool = ApplyConditionalCallback {int};

// use it
IterInt lter = {1, 2, 3, 4};

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
IterInt new_lter = lter
        .map(fn(x) => x * 2, tmem) // temporal allocator
        .for_each(fn(x) => x * 4);


// create a new filtered lter
IterInt lter_filtered = lter
        .filter(fn(num) => num > 23, tmem);
lter_filtered.printn();
// [24, 32]
~~~