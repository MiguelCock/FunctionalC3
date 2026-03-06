module functional::iter <Type>;
import std::core::mem::allocator;
import std::io;

faultdef INDEX_NOT_FOUND;

alias Iter = Type[];
alias ApplyCallback = fn Type (Type);
alias ApplyConditionalCallback = fn bool (Type);
alias ApplyDoubleConditionalCallback = fn bool (Type, Type);


<*
Clones the iter into a new allocation.

Params:
- self: iter to clone
- allocator: allocator used for the copy

Returns:
A new iter containing the same elements.
*>
fn Iter Iter.clone(Iter self, Allocator allocator=tmem)
{
    Iter clone = allocator::new_array(allocator,Type,self.len);
    mem::copy(clone,self,$sizeof(self));
    return clone[:self.len];
}

<*
Frees memory associated with this iter.

Params:
- self: iter to free
- allocator: allocator tied to the allocation

Returns:
Nothing.
*>
fn void Iter.free(Iter self, Allocator allocator) => allocator::free(allocator, self); 


<*
Prints the iter followed by a newline.

Params:
- self: iter to print

Returns:
Nothing.
*>
macro Iter.printn(Iter self) => io::printn(self); 

<*
Applies a function to each element in-place.

Params:
- self: iter to modify
- func: function applied to each element

Returns:
The same iter after modification.
*>
fn Iter Iter.for_each(Iter self, ApplyCallback func)
{
    foreach (i, val : self) {
        self[i] = func(val);
    }
    return self;
}


<*
Creates a new iter by applying a function to each element.

Params:
- self: source iter
- func: mapping function
- allocator: allocator used for the new iter

Returns:
A new mapped iter.
@pure
*>
fn Iter Iter.map(Iter self, ApplyCallback func, Allocator allocator)
{
    Iter clone = self.clone(allocator) @pure;

    foreach (i, val : self) {
        clone[i] = func(val) @pure;
    }
    return clone;
}


<*
Builds a new iter containing only elements that satisfy the predicate.

Params:
- self: source iter
- func: filter predicate
- allocator: allocator used for the new iter

Returns:
A new filtered iter.
*>
fn Iter Iter.filter(Iter self, ApplyConditionalCallback func, Allocator allocator)
{
    Iter clone = self.clone(allocator);

    usz counter = 0;
    for (usz i = 0; i < self.len; i++) {
        if (func(self[i])) {
            clone[counter] = self[i];
            counter++;
        }
    }
    clone = ((Type*)allocator::realloc(allocator, clone, counter * Type.sizeof))[:counter];
    return clone;
}


<*
Checks whether any element satisfies the predicate.

Params:
- self: iter to inspect
- func: predicate to test each element

Returns:
true if at least one element matches, otherwise false.
@pure
*>
fn bool Iter.contains(Iter self, ApplyConditionalCallback func)
{
    foreach(item : self) {
        if(func(item) @pure) return true;
    }
    return false;
}


<*
Finds the index of the first element that satisfies the predicate.

Params:
- self: iter to search
- func: predicate used to test elements

Returns:
Index of the matching element, or INDEX_NOT_FOUND.
@pure
*>
fn usz? Iter.find(Iter self, ApplyConditionalCallback func) {
    for(usz i = 0; i < self.len; ++i) {
        if (func(self[i]) @pure) return i;
    }
    return INDEX_NOT_FOUND~;
}


<*
Reverses the iter in-place.

Params:
- self: iter to reverse

Returns:
The same iter after reversal.
*>
fn Iter Iter.reverse(Iter self)
{
    for (usz i = 0; i < self.len / 2; i++) {
        Type tmp = self[i];
        self[i] = self[self.len - 1 - i];
        self[self.len - 1 - i] = tmp;
    }
    return self;
}


<*
Counts how many elements satisfy the predicate.

Params:
- self: iter to inspect
- func: predicate function

Returns:
Number of matching elements.
@pure
*>
fn int Iter.count(Iter self, ApplyConditionalCallback func)
{
    int counter = 0;
    for (usz i = 0; i < self.len; i++) {
        if (func(self[i]) @pure) {
            counter++;
        }
    }
    return counter;
}

<*
Sorts the iter in-place using the comparator.

Params:
- self: iter to sort
- less: comparison function (a < b)

Returns:
Nothing — modifies the iter in-place.
*>
fn void Iter.sort(Iter self, ApplyDoubleConditionalCallback less)
{
    bool swapped = true;
    while (swapped) {
        swapped = false;
        for (usz i = 0; i + 1 < self.len; i++) {
            if (!less(self[i], self[i + 1])) {
                Type tmp = self[i];
                self[i] = self[i + 1];
                self[i + 1] = tmp;
                swapped = true;
            }
        }
    }
}
// sum
// product
// exist
// for all
// chain
