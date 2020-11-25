module YASLL

  import Base: show, length, iterate, map
  import Base: filter, reverse, copy, cat
  import Base: delete!

  export SLList, Nil, Cons, nil, cons, car, cdr,
         head, tail, list, filter, cat, reverse,
         map, copy, delete, delete!

  include("sllist.jl")
end
