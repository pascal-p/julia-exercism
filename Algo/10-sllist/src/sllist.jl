# Adopted and adapted from: DataStructures.jl/src/list.jl

import Base: show, length, iterate
import Base: map, filter, reverse
import Base: copy, cat

abstract type SLList{T} end               ## Abstract Single Linked List

Base.eltype(::Type{<:SLList{T}}) where T = T

mutable struct Nil{T} <: SLList{T} end    ## Concrete Empty sllist

mutable struct Cons{T} <: SLList{T}       ## Concrete sllist (lisp inspired)
  car::T
  cdr::SLList{T}
end

cons(h, t::SLList{T}) where {T} = Cons{T}(h, t)

nil(T) = Nil{T}()
nil() = nil(Any)

car(x::Cons) = x.car
cdr(x::Cons) = x.cdr
head(x::Cons) = x.car
tail(x::Cons) = x.cdr

Base.:(==)(x::Nil, y::Nil) = true
Base.:(==)(x::Cons, y::Cons) = x.car == y.car && x.cdr == y.cdr

function show(io::IO, l::SLList{T}) where T
  if isa(l, Nil)
    if T === Any
      print(io, "nil()")
    else
      print(io, "nil(", T, ")")
    end
  else
    print(io, "list(")
    Base.show(io, car(l))
    for t in cdr(l)
      print(io, ", ")
      Base.show(io, t)
    end
    print(io, ")")
  end
end


#
# list constructors
#

list() = nil()

# heterogenous list
function list(elts...)
  lst = nil()                  ## init empty list
  for ix ∈ length(elts):-1:1   ## add element one by one in reverse order
    lst = cons(elts[ix], lst)
  end
  return lst
end

# mono-type list
function list(elts::T...) where T
  lst = nil(T)                ## init empty list
  for ix ∈ length(elts):-1:1  ## add element one by one in reverse order
    lst = cons(elts[ix], lst)
  end
  return lst
end

length(::Nil) = 0

function length(lst::Cons)
  n = 0
  for i ∈ lst; n += 1; end
  return n
end

iterate(::SLList, ::Nil) = nothing
iterate(lst::SLList, state::Cons=lst) = (state.car, state.cdr)

function reverse(lst::SLList{T}) where T
  revlst = nil(T)
  for h ∈ lst; revlst = cons(h, revlst); end
  return revlst
end

map(f::Base.Callable, lst::Nil) = lst

function map(fn::Base.Callable, lst::Cons{T}) where T
  car = fn(lst.car)
  nlst = cons(car, nil(typeof(car) <: T ? T : typeof(car)))
  for x in lst.cdr
    nlst = cons(fn(x), nlst)
  end

  reverse(nlst)
end

function filter(fn::Function, lst::SLList{T}) where T
  nlst = nil(T)
  for h ∈ lst
    fn(h) && (nlst = cons(h, nlst))
  end

  reverse(nlst)
end

copy(lst::Nil) = lst
copy(lst::Cons) = (reverse ∘ reverse)(lst)

"""
  Concatenate multiple sllist
"""
function cat(lst::SLList, lsts::SLList...)
  T = typeof(lst).parameters[1]
  n = length(lsts)

  for ix ∈ 1:n  ## collect all the types
    T2 = typeof(lsts[ix]).parameters[1]
    T = typejoin(T, T2)
  end

  nlst = nil(T)
  for h ∈ lst; nlst = cons(h, nlst); end

  for ix ∈ 1:n, h ∈ lsts[ix]
    nlst = cons(h, nlst)
  end

  reverse(nlst)
end
