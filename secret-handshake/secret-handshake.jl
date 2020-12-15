const SEC_HSHAKE_CODE = Dict{Int, String}(1 => "wink", 2 => "double blink", 4 => "close your eyes", 8 => "jump", 16 => "reverse")
const BASE = sort(collect(keys(SEC_HSHAKE_CODE)), rev=true)

function secret_handshake(code::Integer)
  code < 0 && throw(ArgumentError("code $(code) must be a non negative integer"))
  code == 0 && (return [])

  code, func = case_16(code, pushfirst!)
  actions = Vector{String}()

  ix = 2
  while code ≥ 1
    count = false

    if code ≥ BASE[ix]
      code -= BASE[ix]
      count = true
    end

    if count
      action = SEC_HSHAKE_CODE[BASE[ix]]
      func(actions, action)
    end

    ix += 1
  end

  actions
end

function secret_handshake(t)
  throw(ArgumentError("Not implemented for this type $(typeof(t))"))
end

function case_16(code::Integer, func::Function)
  count = 0

  while code ≥ BASE[1]
    code -= BASE[1]
    count += 1
  end

  count % 2 == 1 && (func = push!)

  (code, func)
end
