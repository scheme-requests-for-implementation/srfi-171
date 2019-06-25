So... Clojure has this pretty cool thing. Transducers. Rich Hickey introduced them into clojure because they were tired or rewriting reducing functions for every different part of the language. The cool thing about transducers is that they are a generalization of map/filter/take/etc which means you can make them play well with just about any part of your language. That is really awesome. Read on to see why.


## So: about this

The main difference compared to the clojure transducers is of course that these aren't arities of the regular comprehension procedures, but stand-alone procedures.

After reading about transducers, this is what I can make of them. They are more or less the same as clojure's transducers.

Arthur Gleckler, of Scheme Request For Implementation fame asked me to make a SRFI from this, and the WIP document is under srfi.md

## History, explanations and examples

Transducers were introduced to the wider public by Rich Hickey (of Clojure fame) here: https://www.youtube.com/watch?v=6mTbuzafcII and explained more thoroughly here: https://www.youtube.com/watch?v=4KqUvG8HPYo

If you don't want to watch the whole thing: transducers are a generalization of map, filter etc. (map 1+ (list 1 2 3)) is written using transducers as (transduce (tmap 1+) conj (list 1 2 3)). So, more verbose and harder to understand! Hooray!

Seriously though:  it has some benefits. Transducing functions can compose into new transducing functions. This means you can do (filter odd? (map 1+ (list 1 2 3))) but without building intermediate lists: (transduce (compose (tmap 1+) (tfilter odd?)) conj (list 1 2 3)).

For chez, this means that this stupid example:

(transduce (compose (tmap 1+) (tmap 1+) (tfilter odd?) (tmap 1-)) tcount (iota 1000000))

runs in a third of the time of:

(length (map 1- (filter odd? (map  1+ (map 1+ (iota 1000000))))))

almost exclusively because of GC overhead. Increasing the list length to ten million makes the difference even bigger (0.3 vs 1.3s on my computer). In guile the overhead of transducers is much larger, but for ten million elements there is still a non-trivial difference (2.1 vs 2.7s). This is bound to change as guile becomes faster.

It is not a replacement for a named let when it comes to speed, but it is exciting as a general way of defining algorithmic transformations that can be re-used in many different situations. Guile users can check out my repo guile-for-loops for a replacement for named let.


## Documentation

see srfi.md


## Portability

transducers-impl.scm is written in more-or-less portable scheme. The scheme you chose must support case-lambda,  have a gensym procedure and a vector->list like in srfi-43. You also need a proper compose function. 

The only nonportable thing is the hash-table implementation which is guile's own, but it should be easy to port this to srfi-69 style hash tables (or whatever your scheme provides).

## Caveats

Some of the transducers are stateful and are not suitable for use with multi-shot continuations or threading. In fact, only tmap, tfilter, trandom-sample, tflatten, tcat and tmapcat are not stateful.

Licensed under the MPL v.2
