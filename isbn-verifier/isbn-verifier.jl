#
# https://julialang.org/blog/2018/07/iterators-in-julia-0.7/
# https://docs.julialang.org/en/v1/base/collections/
# https://en.wikipedia.org/wiki/International_Standard_Book_Number
#

using Random

const VALID_SUBSTR = vcat(string.(collect(1:10)), ["X"])
const BASE_ISBN13 = [1, 3, 1, 3, 1, 3, 1, 3, 1, 3, 1, 3, 1]
const N_ATTEMPTS = 5  # Max. num of attempt for creating an ISBN code from a given prefix
const ISBN_LEN = 10
const ISBN13_LEN = 13


abstract type  AbstractISBN <: AbstractString end

struct ISBN <: AbstractISBN
  value::String

  function ISBN(cisbn::String)
    !isvalid(ISBN, cisbn) && throw(ArgumentError("$cisbn is NOT a valid ISBN"))
    isbn = split(cisbn, "-") |> s -> join(s)
    new(isbn)
  end
end

struct ISBN13 <: AbstractISBN
  value::String

  function ISBN13(isbn::ISBN)
    cisbn = string("978", isbn)
    @assert isa(cisbn, String)

    isbn = string(cisbn[1:12], checksum(cisbn))
    new(isbn)
  end

  function ISBN13(cisbn::String)
    !isvalid(ISBN13, cisbn) && throw(ArgumentError("$cisbn is NOT a valid ISBN13"))
    isbn = split(cisbn, "-") |> s -> join(s)
    new(isbn)
  end
end


"""
Generate a valid ISBN 10 given a valid prefix (in term of acceptable character: digit or X)
of length less than 10 or 13 if hyphen given
"""
function build_isbn10_from_prefix(prefix::String)::ISBN
  cisbn = split(prefix, "-") |> s -> join(s)
  n =  length(cisbn)
  (n == 0 || n ≥ ISBN_LEN) && throw(ArgumentError("not a prefix!"))

  check_validity(cisbn, n)

  ## Compute partial sum, given prefix
  sum = 0
  for (p, s) in zip(collect(ISBN_LEN:-1:ISBN_LEN - n + 1), split(cisbn, ""))
    sum += parse(Int, s) * p
  end

  isbn, msum = cisbn, sum
  n_att = 0
  while true
    m = ISBN_LEN - n
    for (p, i) in zip(collect(m:-1:2), rand(0:9, m - 1))
      sum += i * p
      isbn = string(isbn, i)
    end

    check_digit = (11 - sum % 11) % 11

    if check_digit > 0
      check_digit = check_digit == 10 ? 'X' : check_digit
      isbn = string(isbn, check_digit)
      break
    end

    ## Redo
    n_att += 1
    n_att ≥ N_ATTEMPTS &&
      throw(ArgumentError("generated ISBN10 is not valid! gave up after $(n_att) attempts"))
    isbn, sum = cisbn, msum
  end

  # Final check
  !is_valid10(isbn) && throw(ArgumentError("generated ISBN10 is not valid!"))
  isbn
end


"""
Generate a valid ISBN 13, given a (pseudo) prefix which does not need to start
with 978, given a valid sequence (only digit) of length less than 13 or 17 if
hyphen given
"""
function build_isbn13_from_prefix(prefix::String)::ISBN
  # TODO...
  cisbn = split(prefix, "-") |> s -> join(s)
  n =  length(cisbn)
  (n == 0 || n ≥ ISBN13_LEN) && throw(ArgumentError("not a prefix!"))

  check_validity13(cisbn, n)

  if !occursin(r"\A978", cisbn)
    cisbn = string("978", cisbn)
    n += 3   # == length(cisbn)
    n ≥ ISBN13_LEN && throw(ArgumentError("not a prefix!"))
  end

  ## Compute partial sum, given prefix
  sum = 0
  for (p, s) in zip(BASE_ISBN13[1:n], split(cisbn, ""))
    sum += parse(Int, s) * p
  end

  isbn, msum = cisbn, sum
  n_att = 0
  while true
    for (p, i) in zip(BASE_ISBN13[n+1:end], rand(0:9, ISBN13_LEN - n - 1))
      sum += i * p
      isbn = string(isbn, i)
    end

    check_digit = (10 - sum % 10) % 10
    isbn = string(isbn, check_digit)
    break

    # FIXME retry - is it required?
  end

  # Final check
  !is_valid13(isbn) && throw(ArgumentError("generated ISBN13 is not valid!"))
  isbn
end


function Base.iterate(iter::AbstractISBN, state=(iter.value[1], 1, 0))
  elem, count, offset = state

  elem === nothing && return nothing
  count ≥ length(iter) && return (elem, (nothing, count, offset))

  if string(elem) == "-"
    offset += 1
    elem = iter.value[count + offset]
  end

  return (elem, (iter.value[count + 1], count + 1, offset))
end


Base.length(iter::AbstractISBN) = length(iter.value)
Base.eltype(iter::AbstractISBN) = String

show(io::IO, isbn::ISBN) = print(io, "$(val[1])-$(val[2:4])-$(val[5:9])-$(val[10])")
show(io::IO, isbn::ISBN13) = print(io, "$(val[1:3])-$(val[4])-$(val[5:7])-$(val[8:12])-$(val[13])")


function isvalid(AbstractISBN, isbn::String)::Bool
  length(isbn) ∉ [ISBN_LEN, ISBN13_LEN, 17] && return false

  ## Get rid of "-"
  isbn = split(isbn, "-") |> s -> join(s)

  length(isbn) == ISBN_LEN && return is_valid10(isbn)
  length(isbn) == ISBN13_LEN && return is_valid13(isbn)

  false
end

isvalid(AbstractISBN, isbn::ISBN)::Bool = return isvalid(AbstractISBN, string("", isbn))
isvalid(AbstractISBN, isbn::ISBN13)::Bool = return isvalid(AbstractISBN, string("", isbn))


function is_valid13(isbn::String)::Bool
  "0" ≤ string(isbn[end]) ≤ "9" || return false

  check_digit = checksum(isbn::String)
  check_digit == -1 && return false

  return check_digit == parse(Int, isbn[end])
end


"""
  Returns ISBN error syndrome, true for a valid ISBN, false for an invalid one.
  isbn must be composed of char between 0 and 9 (last char can be 'X')

  No need for any multitplication
"""
function is_valid10(isbn::String)::Bool
  # !occursin(r"\d\-?\d{3}\-?\d{5}\-?(\d|X)", isbn) && throw(ArgumentError("Not a vild ISBN10"))
  !occursin(r"\A\d\-?\d{3}\-?\d{5}\-?(\d|X)\Z", isbn) && return false

  sum, t = 0, 0
  for ch in isbn[1:end-1]
    t += parse(Int, ch)
    sum += t
  end

  string(isbn[end]) ∉ VALID_SUBSTR && return false  # NOTE: isbn[end] is a Char
  t += uppercase(isbn[end]) == 'X' ? 10 : parse(Int, isbn[end])
  sum += t

  return sum % 11 == 0
end


function checksum(isbn::String)::Int
  "for ISBN13 .,."

  sum, lim = 0, length(isbn) - 1
  for (p, s) in zip(BASE_ISBN13[1:end - 1], split(isbn, ""))
    "0" ≤ s ≤ "9" || return -1
    sum += parse(Int, s) * p
  end

  return (10 - sum % 10) % 10
end


function check_validity(cisbn::String, len::Int)
  "Check validity of prefix in the context of building an ISBN number"

  for s in split(cisbn, "")[1:len-1]
    !("0" ≤ string(s) ≤ "9") && throw(ArgumentError("not a valid prefix!"))
  end

  cond = if len < ISBN_LEN
    "0" ≤ string(cisbn[end]) ≤ "9"
  else
    "0" ≤ string(cisbn[end]) ≤ "9" || (uppercase ∘ string)(cisbn[end]) == "X"
  end
  !cond && throw(ArgumentError("not a valid prefix!"))
end


function check_validity13(cisbn::String, len::Int)
  "Check validity of prefix in the context of building an ISBN13 number"

  for s in split(cisbn, "")
    !("0" ≤ string(s) ≤ "9") && throw(ArgumentError("not a valid prefix!"))
  end
end


macro isbn_str(isbn::String)
  return ISBN(isbn)
end


macro isbn13_str(isbn::String)
  return ISBN13(isbn)
end
