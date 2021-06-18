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
  ## check msg, rails
  msg = replace(msg, NON_LETTERS => "")

  ## distribute the chars on the rails
  n = length(msg)
  rows = fill_rails(msg, rails)

  ## get the non '.' chars from a row(rail)
  λ(r) = filter(ch -> ch != DEFL, rows[r])

  ## accumulate all chars in one array and stringify
  foldl((a, jx) -> (push!(a, λ(jx)...); a),
        collect(1:rails);
        init=[]) |>
    a -> join(a, "")
end

@enc_dec_checker function decode(msg::String, rails::Int)::String
  ## 1 - fill with placeholder
  n = length(msg)
  rows = fill_rails("?" ^ n, rails)

  ## 2 - replace placeholder
  repl_placeholder!(msg, rows, rails)

  ## 3 - finally decode
  read_rails(rows, rails)
end

##
## internals
##

function init_rows(n::Int, rails::Int)
  [fill('.', n) for _ in 1:rails]
end

function repl_placeholder!(msg, rows, rails)
  lix = 1
  for r in 1:rails, ix in 1:length(rows[r])
    if rows[r][ix] == '?'
      rows[r][ix] = msg[lix]
      lix += 1
    end
    ix += 1
  end
end

function read_rails(rows, rails::Int)
  n = length(rows[1]) ## Assume all rails have same lengths
  msg = ""

  function read_incr(ix)
    s, e = 1, rails
    for r in s:e
      msg = string(msg, rows[r][ix])
      ix += 1
      ix > n && break
    end
    return ix
  end

  function read_decr(ix)
    s, e = rails - 1, 2
    for r in s:-1:e
      msg = string(msg, rows[r][ix])
      ix += 1
      ix > n && break
    end
    return ix
  end

  @loop(n, read_incr, read_decr)
  msg
end

function fill_rails(msg::String, rails::Int; defl=DEFL)
  n = length(msg)
  rows = init_rows(n, rails)

  function fill_incr(ix)
    s, e = 1, rails
    for r in s:e
      rows[r][ix] = msg[ix]
      ix += 1
      ix > n && break
    end
    return ix
  end

  function fill_decr(ix)
    s, e = rails - 1, 2
    for r in s:-1:e
      rows[r][ix] = msg[ix]
      ix += 1
      ix > n && break
    end
    return ix
  end

  @loop(n, fill_incr, fill_decr)
  rows
end
