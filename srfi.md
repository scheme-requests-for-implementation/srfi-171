---
pagetitle: "SRFI-??? Transducers"
---

Title
=====

Transducers

Author
======

Linus Björnstam <bjornstam.linus@fastmail.se>

Status
======

???

Abstract
========

A library implementing transducers - composable algorithmic
transformations. Scheme has many different ways of expressing
transformations over different collection types, but they are all unique
to whatever base type they work on. This srfi proposes a new construct,
the transducer, that is oblivious to the context of which it is being
used

Issues
======

State
-----

We have the issue of state to handle. Hidden state is ugly, but at the
same time passing state with the transduction means quite a lot of extra
housekeeping. The simplest solution would be to pass the current result
wrapped with a list of states, i.e: (cons result state) where each
transducer that is keeping state is responsible for moving it forward.
It would not matter in the context of user-facing functions such as
transduce, but would be somewhat of a burden when used as a regular step
in other transformations.

That simple solution would mean removing tail-call elimination for
state-keeping transducers, but that might be a cost worth having. Any
suggestions are welcome.

I also don\'t know how that would play with some compiler optimizations.
Chez seems to be able to efficiently inline a lot, completely removing a
lot of the work (ie (transduce (tmap ...) ...) is almost as fast as (map
...))

Naming
------

Another question is whether transducers like tcat and tdedupe should be
different from procedures that return transducers (like tmap). As it is
now, you have to run (tdedupe), which really isn\'t necessary.

What to export
--------------

In the reference implementation, collection-transduce dispatches to a
reducing function. They are used in parts of the reference
implementation (tflatten and tcat), and they aren\'t a must-have since
the usages in the reference implementation could be rewritten to use
transduce. There might be cases where one just wants to use the reducer
you have, and if you want to use it with transduce you would then need a
\"null-transducer\" that does nothing.

I want to export these procedures, but then the naming needs to change.
Suddenly having list/vector/string/bytevector-reduce is weird. Should
they be exported and what should they be called? They behave like reduce
from srfi-1, apart from checking for reduced values, but it still
doesn\'t feel right.

Rationale
=========

Some of the most common operations used in the scheme language are those
transforming list: map, filter, take and so on. They work well, are well
understood and are used daily by most scheme programmers. They are
however not general because they only work on lists, and they do not
compose very well since combining N of them builds (- N 1) intermediate
lists.

Transducers are oblivious to what kind of process they are used in, and
are composable without building intermediate collections. This means we
can create a transducer that squares all even numbers: (compose (tfilter
odd?) (tmap (lambda (x) (\* x x)))) and reuse it with lists, vectors or
in just about any context where data flows in one direction. We could
use it as a processing step for asynchronous channels, with an event
framework as a pre-processing step or even in lazy contexts where you
pass lazy collection and a transducer to a function and get a new lazy
collection back.

The traditional scheme approach of having collection-specific procedures
is not changed. We instead specify a general form of transformations
that complement these procedures. The benefits are obvious: We get a
clear, well understood way of describing common transformations in a way
that is faster than just chaining the collection-specific counterparts.
Even for slower schemes where the overhead of transducers is big, the
effects on garbage collection times are often dramatic, making
transducers a very attractive.

Dependencies
------------

The reference implementation of transducers depends on the following:

-   srfi-9, define-record-type
-   A hash-table implementation
-   Proper compose procedure (included if it is not available)
-   A vector-\>list that behaves like in srfi-43

Portability
-----------

The reference implementation is easily portable to any
r5rs/r6rs-compatible scheme. The non-standard things are:

-   a vector-\>list that takes a start and end argument
-   hash tables with support for set, get and discovering if an key
    exists.
-   case-lambda (preferably efficiently implemented).

General discussion
==================

Even though transducers are somewhat of a generalisation of map and
friends, this is not really true. Since transducers don\'t know about
which context they are being used, some transducers must keep state
where their collection-specific counterparts do not. This SRFI requires
some transducers to be stateless (as is stated in the documentation of
each transducer), but many are allowed to keep state.

The central part of transducers are 3-arity reducing functions.

-   (): Produce an identity
-   (result-so-far): completion. If you have nothing to do, then just
    return the result so far
-   (result-so-far input) do whatever you like to the input and produce
    a new result-so-far

In the case of a summing + reducer the reducer would produce, in arity
order: 0, result-so-far, (+ result-so-far input). This happens to be
exactly what the regular + does.

A transducer is a one-arity function that takes a reducing function (in
the list below called simply \"reducer\") and produces a reducing
function that behaves as follows:

-   (): calls reducer with no arguments (producing it\'s identity)
-   (result-so-far): Maybe transform the result-so-far and call reducer
    with it.
-   (result-so-far input) Maybe do something to input and maybe call the
    reducer with result-so-far and the maybe-transformed input.

A simple example is as following: (transduce (tfilter odd?) + \'(1 2 3 4
5)). This first returns a transducer filtering all odd elements, then it
runs + without arguments to retrieve it\'s identity. It then starts the
transduction by passing + to the transducer returned by (tfilter odd?)
which returns a reducing function. It works not unlike reduce from
srfi-1, but also checks whether one of the intermediate transducers
returns a \"reduced\" value (implemented as a srfi-9 record), which
means the reduction finished early.

Because transducers compose and the final reduction is only executed in
the last step, composed transducers will not build any intermediate
result or collections. Although the normal way of thinking about
application of composed functions is right to left, due to how the
transduction is built it is applied left to right. (compose (tfilter
odd?) (tmap sqrt)) will create a transducer that first filter out any
odd values and computes the square root of the rest.

Naming
------

Transducers and procedures that return transducers all have names
starting with t. Reducing functions that are supposed to be used at the
end of a transduction all start with r. Some reducers are just straight
up reducers, whereas others (like rany and revery) are procedures that
returns reducers.

Scope considerations
--------------------

The procedures specified here are only for the collections defined in
r7rs-small. They could easily be extended to support r7rs-large red
docket, but specifying that would require conforming implementations to
also support a substantial part of the red docket. I therefore leave
transduce unspecified for many data types. It is however encouraged to
add \[datatype\]- transduce for whatever types your scheme supports.
Adding support for the collections of the red docket (sets, hash-tables,
ilists, rlists, ideque, texts, lseqs, streams, generators and
list-queues) is trivial.

The transduce form is always eager, and any general lazy application of
transducers is outside the scope of this SRFI.

Specification
=============

Applying transducers
--------------------

### transduce

*(list-transduce xform f lst)\
(list-transduce xform f identity lst)*

Initializes the transducer xform by passing the reducer f to it. If no
identity is provided, f is run without arguments to return the reducer
identity. It then reduces over lst using the identity as the seed.

If one of the transducers finishes early (such as ttake or tdrop), it
communicates this by returning a reduced value, which in the reference
implementation is just a value wrapped in a srfi-9 record type named
\"reduced\". If such a value is returned by the transducer,
list-transduce must stop execution immediately.

### vector-transduce

*(vector-transduce xform f vec)\
(vector-transduce xform f identity vec)*

Same as transduce, but reduces over a vector instead of a list.

### string-transduce

*(string-transduce xform f str)\
(string-transduce xform f identity str)*

Same as transduce, but for strings.

### bytevector-transduce

*(bytevector-transduce xform f bvec)\
(bytevector-transduce xform f identity bvec)*

Same as transduce, but for bytevectors.

Reducers
--------

### rcons

a simple consing reducer. Whin called without values, it returns it\'s
identity: \'(), with one value (which will be a list) it reverses the
list. When called with two values it conses the second value to the
first.

May use non-linear reverse! at the end.

(transduce (tmap add1) rcons (list 0 1 2 3)) =\> (1 2 3 4)

### reverse-rcons

same as rcons, but leaves the values in their reversed order.

(transduce (tmap add1) reverse-rcons (list 0 1 2 3)) =\> (4 3 2 1)

### (rany pred?)

The reducer version of any. Returns (reduced (pred? value)) if any
(pred? value) returns truthy. The identity is \#f.

(transduce (tmap (lambda (x) (+ x 1))) (rany odd?) (list 1 3 5)) =\> \#f
(transduce (tmap (lambda (x) (+ x 1))) (rany odd?) (list 1 3 4 5)) =\>
\#t

### (revery pred?)

The reducer version of every. Stops the transduction and returns
(reduced \#f) if any (pred? value) returns \#f. If every (pred? value)
returns true, it returns the result of the last invocation of (pred?
value).

(transduce (tmap add1) (revery (lambda (v) (if (odd? v) v \#f))) (list 2
4 6)) =\> 7 (transduce (tmap add1) (revery odd?) (list 2 4 5 6)) =\> \#f

### rcount

A simple counting reducer. Counts the values that pass through the
transduction.

(transduce (tfilter odd?) rcount (list 1 2 3 4)) =\> 2.

Transducers
-----------

### (tmap proc)

Returns a transducer that applies proc to all values. Must be stateless.

### (tfilter pred)

Returns a transducers that removes values for which pred returns \#f.
Must be stateless.

### (tremove pred)

Returns a transducer that removes values for which pred returns truthy.
Must be stateless.

### (tfilter-map proc)

The same as (compose (tmap proc) (tfilter values)). Must be stateless.

### (treplace map)

Returns a transducer which uses any value as a key in *map*. If a
mapping is found, the value of that mapping is returned, othervise it
just returns the original value.

Must not keep any internal state. Modifying the map after treplace has
been instantiated is an error.

### (tdrop n)

Returns a transducer that discards the first n values.

Stateful.

### (ttake n)

Returns a transducer that discards all values and stops the transduction
after the first n values have been let through. Any subsequent values
are ignored.

Stateful

### (tdrop-while pred?)

Returns a transducer that discards the the first values for which pred?
returns true.

Stateful

### (ttake-while pred?)

Returns a transducer that stops the transduction after pred? has
returned \#f. Any subsequent values are ignored and the last successful
value is returned.

Stateful

### (thalt-when pred? *\[retf\]*)

Returns a transducer that stops the transduction if pred? returns true
for a value. retf must be a function of 2 arguments that is passed the
completed result so far and the value for which pred? returned true. If
retf is not supplied it is the same thing as (halt-when pred? (lambda
(result-so-far value) value)). When called after it has stopped the
transduction, it will always return the same value.

Is only useful together with transduce and will probably lead to errors
in other contexts.

Stateful

### tcat

Tcat **is** a transducer that concatenates the content of each value
(that must be a list) into the reduction.

(transduce tcat rcons \'((1 2) (3 4 5) (6 (7 8) 9))) =\> (1 2 3 4 5 6 (7
8) 9)

### (append-map proc)

The same as (compose (tmap proc) tcat).

### (tdedupe)

Returns a transducer that removes consecutive duplicate elements.

Stateful.

### (tremove-duplicates)

Returns a transducer that removes any duplicate elements.

Stateful.


### (tflatten)

Returns a transducer that flattens an input consisting of lists.

(transduce (tflatten) rcons \'((1 2) 3 (4 (5 6) 7 8) 9) =\> (1 2 3 4 5 6
7 8 9)

### (tpartition-all n)

Returns a transducer that groups n inputs in lists of n elements. When
the transduction stops it flushes any remaining collection, even if it
contains less than n elements.

Stateful.

### (tpartition-by pred?)

Returns a transducer that groups inputs in lists by whenever (pred?
input) changes value.

Stateful.

### (tindex *\[start\]*)

Returns a transducer that indexes values passed through it, starting at
*start* which defaults to 0. The indexing is done through cons pairs
like (index . input).

Stateful

### (tlog *\[logger\]*)

Returns a transducer that can be used to log or print values and
results. The result of the logger procedure is discarded. The default
logger is (lambda (input result) (write input) (newline))

Reference implementation
========================

The reference implementation is written in Guile, but should be
straight-forward to port since it uses no guile-specific features apart
from guile\'s hash-table implementation. In fact, I am quite certain
that It is written for clarity instead of speed, but should be plenty
fast anyway. The low hanging fruit for optimization is to replace the
composed transducers (such as tappend-map and tfilter-map) with actual
implementations.

Acknowledgements
================

First of all, this would not have been done without Rich Hickey who
introduced transducers into clojure. His talks were important for me to
grasp the basics of transducers. Then I would like to thank large parts
of the Clojure community for also struggling with understanding
transducers. The amount of material produced explaining them in general,
and clojure\'s implementation specifically, has been instrumental in
letting me make this a clean-room implementation.

Lastly I would like to thank Arthur Gleckler who showed interest in my
implementation of transducers and convinced me to make this SRFI.


Copyright
=========
Copyright (C) Linus Björnstam (2019).

 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 
