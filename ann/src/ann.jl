using StableRNGs

##
## Model
##

struct ANN{T}
  parms::Dict{String, Array{T, N} where N}
  η::T

  function ANN{T}(layer_dims::Vector{T1};
                  seed=42, init=:He, η=T(0.0001)) where {T, T1 <: Integer}

    parms = Dict{String, Matrix{T}}()

    for l ∈ 2:length(layer_dims)
      key_w, key_b = string("w", l-1), string("b", l-1)
      parms[key_w] = rand(StableRNG(seed), layer_dims[l], layer_dims[l-1])
      if init == :He
        parms[key_w] *= √(2 / layer_dims[l-1])
      end
      parms[key_b] = zeros(layer_dims[l], 1)
    end
    new(parms, η)
  end

  function ANN{T}(parms::Dict{String, Array{T, N} where N}; η=T(0.0001)) where T
    new(parms, η)
  end
end


function update_ann_model!(ann::ANN{T}, ∇) where {T <: Real}
  l_len = length(ann.parms) ÷ 2

  for l ∈ 1:l_len
    key_w, key_b = string("w", l), string("b", l)
    ann.parms[key_w] -= ann.η .* ∇[string("∂", key_w)]
    ann.parms[key_b] -= ann.η .* ∇[string("∂", key_b)]
  end
end


function train_ann_model(layer_dims, x::Matrix{T}, y::Matrix{T};
                         seed=42, init=:He, η=0.0001, epochs=1_000, threshold=0.5, verbose=true) where {T <: Real}
  costs = Vector{T}(undef, epochs)
  accuracy = Vector{T}(undef, epochs)
  iters = Vector{Int}(undef, epochs)

  ann = ANN{T}(layer_dims; seed, init, η)

  for ix ∈ 1:epochs
    ŷ, caches = forward_pass(ann, x)

    cost = cost_fn(ŷ, y)
    acc = accuracy_fn(ŷ, y; threshold)

    ∇ = backward_pass(ŷ, y, caches)
    update_ann_model!(ann, ∇)

    verbose && println("Epoch $(ix) / $(epochs) - cost: $(cost) - accuracy: $(acc)")

    costs[ix] = cost
    accuracy[ix] = acc
    iters[ix] = ix
  end

  return (epochs=iters, cost=costs, accuracy=accuracy, parms=ann.parms)
end



##
## activation functions / derivatives of activation functions
##

function sigmoid_afn(z)
  a = 1. ./ (1. .+ exp.(.-z))
  return (a=a, z=z)
end

function relu_afn(z)
  a = max.(0.0, z)
  return (a=a, z=z)
end

function softmax_afn(z)
  # TODO
end

function der_sigmoid_afn(∂a, act_cache)
  s = sigmoid_afn(act_cache).a
  ∂z = ∂a .* s .* (1. .- s)
  @assert size(∂z) == size(act_cache)
  return ∂z
end

function der_relu_afn(∂a, act_cache)
  ∂a .* (act_cache .> 0.0)
end

function der_softmax_afn(∂a, act_cache)
  # TODO
end



##
## forward pass
##

"""
  Zˡ = Wˡ × Aˡ⁻¹ + bˡ
  Aˡ = σ(Zˡ)
"""
function linear_forward(a, w, b)
  z = (w * a) .+ b
  cache = (a, w, b)

  @assert size(z) ≡ (size(w, 1), size(a, 2))

  return (Z=z, Cache=cache)
end

function linear_forward_activation(aₚ, w, b; activation_fn=relu_afn)
  @assert Symbol(activation_fn) ∈ ACTIVATION_FN "Expecting $(Symbol(activation_fn)) to be in $(ACTIVATION_FN)"

  (z, linear_cache) = linear_forward(aₚ, w, b)
  (a, activ_cache) = activation_fn(z)

  @assert size(a) ≡ (size(w, 1), size(a, 2))
  (a, (Linear_Step_Cache=linear_cache,
       Activation_Step_Cache=activ_cache))
end



##
## cost / accuracy
##

"""
  Binary cross-entropy cost function
  J =  - 1/m Σᵢᵐ Yⁱ × log(Ŷⁱ) + (1 - Yⁱ) × log(1 - Ŷⁱ)
"""
function cost_fn(ŷ, y)
  m = size(y, 2)
  ϵ = eps(1.0)

  ŷₙ = max.(ŷ, ϵ)
  ŷₙ = min.(ŷₙ, 1 - ϵ)

  - sum(y .* log.(ŷₙ) + (1 .- y) .* log.(1 .- ŷₙ)) / m
end

function accuracy_fn(ŷ, y; threshold=0.5)
  @assert size(ŷ) ≡ size(y)

  sum((ŷ .> threshold) .== y) / length(y)
end



##
## backward pass
##

function linear_backward(∂z, cache)
  aₚ, w, b = cache
  m = size(aₚ, 2)

  ∂w = ∂z * aₚ' / m
  ∂b = sum(∂z, dims=2) / m
  ∂b = reshape(∂b, size(b))
  ∂aₚ = w' * ∂z

  @assert size(∂w) == size(w)
  @assert size(∂b) == size(b)
  @assert size(∂aₚ) == size(aₚ)

  return (∂w, ∂b, ∂aₚ)
end

function linear_backward_activation(∂a, cache; activation_fn=relu_afn)
  @assert Symbol(activation_fn) ∈ ACTIVATION_FN "Expecting $(Symbol(activation_fn)) to be in $(ACTIVATION_FN)"

  linear_cache, activ_cache = cache
  ∂z = getfield(@__MODULE__, Symbol(string("der_", activation_fn)))(∂a, activ_cache)

  (∂w, ∂b, ∂aₚ) = linear_backward(∂z, linear_cache)

  return (∂w, ∂b, ∂aₚ)
end


##
## forward pass, backward pass
##

function forward_pass(ann::ANN{T}, x::Matrix{T}) where T
  a = x
  l_len = length(ann.parms) ÷ 2
  meta_cache = []

  ## forward propagate until penultimate layer (last layer before output)
  for l ∈ 1:l_len-1
    aₚ = a
    key_w, key_b = string("w", l), string("b", l)
    a, cache = linear_forward_activation(aₚ, ann.parms[key_w], ann.parms[key_b])  # using relu
    push!(meta_cache, cache)
  end

  ## make predictions with output layer
  key_w, key_b = string("w", l_len), string("b", l_len)
  ŷ, cache = linear_forward_activation(a, ann.parms[key_w], ann.parms[key_b];
                                       activation_fn=sigmoid_afn)
  push!(meta_cache, cache)

  return (ŷ, meta_cache)
end

function backward_pass(ŷ, y, meta_cache)
  ∇ = Dict()

  l_len, y = length(meta_cache), reshape(y, size(ŷ))

  ## partial deriv. of output layer
  ∂ŷ = - (y ./ ŷ) .+ (1 .- y) ./ (1 .- ŷ)
  curr_cache = meta_cache[l_len]

  d_w, d_b, d_a = string("∂w", l_len), string("∂b", l_len), string("∂a", l_len - 1)
  ∇[d_w], ∇[d_b], ∇[d_a] = linear_backward_activation(∂ŷ, curr_cache;
                                                      activation_fn=sigmoid_afn)
  ## now go backward through all layers until input one
  for l ∈ l_len-2:-1:0
    curr_cache = meta_cache[l+1]
    d_w, d_b, d_a = string("∂w", l+1), string("∂b", l+1), string("∂a", l)
    ∇[d_w], ∇[d_b], ∇[d_a] = linear_backward_activation(∇[string("∂a", l+1)], curr_cache)
  end

  ∇
end

const ACTIVATION_FN = filter(s -> match(r".+_afn\z", string(s)) != nothing && match(r"\Ader_", string(s)) == nothing,
                             names(@__MODULE__; all=true, imported=false))
