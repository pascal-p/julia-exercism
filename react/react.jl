# const T <: integer

abstract type Cell{T <: Integer} end

mutable struct InputCell{T} <: Cell{T}
  value::T
  observers::Set{Cell{T}}

  function InputCell{T}(value::T) where T
    observers = Set{Cell{T}}()
    new(value, observers)
  end
end

mutable struct ComputeCell{T} <: Cell{T}
  inputs::Vector{<: Cell{T}}
  fn::Function
  value::T
  observers::Set{Cell{T}}
  callbacks::Set{Function}

  function ComputeCell{T}(inputs::Vector{<: Cell{T}}, fn) where T
    observers = Set{Cell{T}}()
    callbacks = Set{Function}()
    value = _calc(fn, inputs)
    cc = new(inputs, fn, value, observers, callbacks)
    for inp ∈ inputs
      push!(inp.observers, cc)
    end
    cc
  end
end


_calc(fn::Function, inputs::Vector{<: Cell{T}}) where T = map(x -> x.value, inputs) |> lval -> fn(lval)

## InputCell API
function propagate(ic::InputCell)
  q_ccells = vcat(ic.observers...)

  while length(q_ccells) > 0
    ccell = q_ccells[1]
    # q_ccells = q_ccells[2:end]
    re_calc(ccell)
    q_ccells = [
      q_ccells[2:end]...,
      vcat(ccell.observers...)...
    ]
  end
end

# The syntax a.b = c calls setproperty!(a, :b, c).
function Base.setproperty!(ic::InputCell, symb::Symbol, val::T) where T
  if symb == :value
    ex_val = ic.value
    setfield!(ic, :value, val) # ic.value = val # => dangerous: will loop forever
    ex_val != val && propagate(ic)
  else
    throw(KeyError("attribute $(symb) not yet? supported"))
  end
end


## ComputeCell API
add_callback(cc::ComputeCell, cb::Function) = push!(cc.callbacks, cb)
remove_callback(cc::ComputeCell, cb::Function) = delete!(cc.callbacks, cb)
function invoke_callbacks(cc::ComputeCell)
  for cb ∈ cc.callbacks
    cb(cc.value)
  end
end

calc(cc::ComputeCell) = cc.value = _calc(cc.fn, cc.inputs)

function re_calc(cc::ComputeCell)
  ex_val = cc.value
  calc(cc)
  cc.value != ex_val && (invoke_callbacks(cc))
end
