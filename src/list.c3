module functional::list <Type>;
import std::core::mem::allocator;
import std::io;

faultdef INDEX_NOT_FOUND;

alias List = Type[];
alias ApplyCallback = fn Type (Type);
alias ApplyConditionalCallback = fn bool (Type);
alias ApplyDoubleConditionalCallback = fn bool (Type, Type);


<*
Clones the list into a new allocation.

Params:
- self: list to clone
- allocator: allocator used for the copy

Returns:
A new list containing the same elements.
*>
fn Type[] Type[].clone(Type[] self, Allocator allocator=tmem)
{
    Type[] clone = allocator::new_array(allocator,Type,self.len);
    mem::copy(clone,self,$sizeof(self));
    return clone[:self.len];
}

<*
Frees memory associated with this list.

Params:
- self: list to free
- allocator: allocator tied to the allocation

Returns:
Nothing.
*>
fn void Type[].free(Type[] self, Allocator allocator) => allocator::free(allocator, self); 


<*
Prints the list followed by a newline.

Params:
- self: list to print

Returns:
Nothing.
*>
macro Type[].printn(Type[] self) => io::printn(self); 

<*
Applies a function to each element in-place.

Params:
- self: list to modify
- func: function applied to each element

Returns:
The same list after modification.
*>
fn Type[] Type[].for_each(Type[] self, ApplyCallback func)
{
    foreach (i, val : self) {
        self[i] = func(val);
    }
    return self;
}


<*
Creates a new list by applying a function to each element.

Params:
- self: source list
- func: mapping function
- allocator: allocator used for the new list

Returns:
A new mapped list.
@pure
*>
fn Type[] Type[].map(Type[] self, ApplyCallback func, Allocator allocator)
{
    Type[] clone = self.clone(allocator) @pure;

    foreach (i, val : self) {
        clone[i] = func(val) @pure;
    }
    return clone;
}


<*
Builds a new list containing only elements that satisfy the predicate.

Params:
- self: source list
- func: filter predicate
- allocator: allocator used for the new list

Returns:
A new filtered list.
*>
fn Type[] Type[].filter(Type[] self, ApplyConditionalCallback func, Allocator allocator)
{
    Type[] clone = self.clone(allocator);

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
- self: list to inspect
- func: predicate to test each element

Returns:
true if at least one element matches, otherwise false.
@pure
*>
fn bool Type[].contains(Type[] self, ApplyConditionalCallback func)
{
    foreach( item : self) {
        if(!func(item) @pure) return true;
    }
    return false;
}


<*
Finds the index of the first element that satisfies the predicate.

Params:
- self: list to search
- func: predicate used to test elements

Returns:
Index of the matching element, or INDEX_NOT_FOUND.
@pure
*>
fn usz? Type[].find(Type[] self, ApplyConditionalCallback func) {
    for(usz i =0;self.len;++i) {
        if (func(self[i]) @pure) return i;
    }
    return INDEX_NOT_FOUND~;
}


<*
Reverses the list in-place.

Params:
- self: list to reverse

Returns:
The same list after reversal.
*>
fn Type[] Type[].reverse(Type[] self)
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
- self: list to inspect
- func: predicate function

Returns:
Number of matching elements.
@pure
*>
fn int Type[].count(Type[] self, ApplyConditionalCallback func)
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
Sorts the list in-place using the comparator.

Params:
- self: list to sort
- less: comparison function (a < b)

Returns:
Nothing — modifies the list in-place.
*>
fn void Type[].sort(Type[] self, ApplyDoubleConditionalCallback less)
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
