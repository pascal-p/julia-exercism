# using Plots
# using MLJBase
using StableRNGs


##
## Model
##

function init_model(layer_dims::Vector{Integer}; seed=42, init=He)
  # TODO
end

function update_model(parms, ∇; η=0.0001)
  # TODO
end

function train_model(layer_dims, DMatrix, y; η=0.0001, epochs=1_000, seed=42, init=He, threshold=0.5, verbose=true)
  costs = Vector{Float}(undef, epochs)
  accuracy = Vector{Float}(undef, epochs)
  iters = Vector{Int}(undef, epochs)

  parms = init_model(layer_dims; seed, init)

  for ix ∈ 1:epochs
    ŷ, caches = forward_pass(DMatrix, parms)

    cost = cost_fn(ŷ, y)
    acc = accuracy_fn(ŷ, y; threshold)

    ∇ = backward_pass(ŷ, y, caches)
    parms = update_model(parms, ∇; η)

    verbose && println("Epoch $(ix) / $(epochs) - cost: $(cost) - accuracy: $(acc)")

    costs[ix] = cost
    accuracy[ix] = acc
    iters[ix] = ix
  end

  return (epochs=iters, cost=costs, accuracy=accuracy, parms=parms)
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
  # TODO
end

function linear_forward_activation(aₚ, w, b; activation_fn=relu_afn)
  # TODO
end

##
## cost / accuracy
##

"""
  Binary cross-entropy cost function
  J =  - 1/m Σᵢᵐ Yⁱ × log(Ŷⁱ) + (1 - Yⁱ) × log(1 - Ŷⁱ)
"""

function cost_fn(ŷ, y)
  # TODO
end

function accuracy_fn(ŷ, y; threshold=0.5)
  # TODO
end

##
## backward pass
##

function linear_backward(∂z, cache)
  # TODO
end

function linear_backward_activation(∂a, cache; activation_fn=relu_afn)
  #TODO
end


##
## forward pass, backward pass
##

function forward_pass(DMatrix, params)
  # TODO
end

function backward_pass(ŷ, y, meta_cache)
  # TODO
end
