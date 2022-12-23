const NON_LETTERS = r"[^a-zA-Z0-9]+"
const DEFL = '.'

## A convenience macro
macro loop(n, incr_fn, decr_fn)
  quote
    local ix = 1
    while true
      ix = $(esc(incr_fn))(ix)
      ix > $(esc(n)) && break
      ix = $(esc(decr_fn))(ix)
      ix > $(esc(n)) && break
    end
  end
end

function check_fn(msg::String, rails::Int)::Bool
  rails == 1 && return false
  (length(msg) == 0  || rails > length(msg)) && return false
  rails ≤ 0 && throw(ArgumentError("rails should be strictly positive - got: $(rails)"))
  true
end

macro enc_dec_checker(fn)
  """
  Aim: inject check_fn function to check whether the given args are acceptable
       (which raises an exception if not)

  With: @enc_dec_checker function encode(msg::String, rails::Int)::String
  We have the following:

    fn.args[1]                         == encode(msg::String, rails::Int)::String
    fn.args[1].args[1]                 == encode(plain::AbstractString, rails::Int)
    fn.args[1].args[2]                 == String
    fn.args[1].args[1].args[1]         == encode
    fn.args[1].args[1].args[2]         == msg::String,
    fn.args[1].args[1].args[3]         == rails::Int
    fn.args[2]                         == whole body of fn
  """
  if typeof(fn) == Expr
    ## extract var and build checker
    local msg = fn.args[1].args[1].args[2].args[1]
    local rails = fn.args[1].args[1].args[3].args[1]

    ## Inject checker in body of wrapped function
    fn.args[2] = :(begin
      check_fn($(msg), $(rails)) || (return $(msg))
      $(fn.args[2])
    end)
  end

  return fn
end

@enc_dec_checker function encode(msg::String, rails::Int)::String
  ## 1 - check msg, rails, distribute the chars on the rails
  rows = replace(msg, NON_LETTERS => "") |>
    msg -> fill_rails(msg, rails)

  ## 2 - get the non '.' chars from a row(rail)
  λ(r) = filter(ch -> ch != DEFL, rows[r])

  ## 3 - accumulate all chars in one array and stringify
  foldl((a, jx) -> (push!(a, λ(jx)...); a),
        collect(1:rails);
        init=[]) |>
    a -> join(a, "")
end

@enc_dec_checker function decode(msg::String, rails::Int)::String
  ## fill with placeholder, and replace it
  fill_rails("?" ^ length(msg), rails) |>
    rows -> repl_placeholder!(msg, rows, rails) |>
    rows -> read_rails(rows, rails)
end

##
## internals
##

init_rows(n::Int, rails::Int) = [fill('.', n) for _ in 1:rails]

function repl_placeholder!(msg, rows, rails)
  lix = 1
  for r ∈ 1:rails, ix ∈ 1:length(rows[r])
    if rows[r][ix] == '?'
      rows[r][ix] = msg[lix]
      lix += 1
    end
  end
  rows
end

function read_rails(rows, rails::Int)
  n = length(rows[1]) ## Assume all rails have same lengths
  msg = ""

  readfn = function(ix, start_, end_; incr=1)
    for r ∈ start_:incr:end_
      msg = string(msg, rows[r][ix])
      ix += 1
      ix > n && break
    end
    ix
  end

  read_incr(ix) = readfn(ix, 1, rails)
  read_decr(ix) = readfn(ix, rails - 1, 2; incr=-1)

  @loop(n, read_incr, read_decr)
  msg
end

function fill_rails(msg::String, rails::Int; defl=DEFL)
  n = length(msg)
  rows = init_rows(n, rails)

  # fillfn = function(ix, start_, end_; incr=1)
  #   for r ∈ start_:incr:end_
  #     rows[r][ix] = msg[ix]
  #     ix += 1
  #     ix > n && break
  #   end
  #   ix
  # end

  # fill_incr(ix) = fillfn(ix, 1, rails)
  # fill_decr(ix) = fillfn(ix, rails - 1, 2; init = -1)

  fill_incr = function(ix)
    s, e = 1, rails
    for r ∈ s:e
      rows[r][ix] = msg[ix] # side-effect rows for fill_decr
      ix += 1
      ix > n && break
    end
    ix
  end

  fill_decr = function(ix)
    s, e = rails - 1, 2
    for r ∈ s:-1:e
      rows[r][ix] = msg[ix] # side-effect rows for fill_incr
      ix += 1
      ix > n && break
    end
    ix
  end

  @loop(n, fill_incr, fill_decr)
  rows
end
