### A Pluto.jl notebook ###
# v0.12.18

using Markdown
using InteractiveUtils

# ╔═╡ ab815d22-5b63-11eb-2f45-81b70732b6b2
using StableRNGs

# ╔═╡ 38958a82-5b64-11eb-22dc-37be1aaa9056
using Test

# ╔═╡ 1ca31664-5b6e-11eb-05e4-f3f15fb7abab
using PlutoUI

# ╔═╡ b973db3a-5b60-11eb-1e10-0f1558cff343
md"## Building our own Artificial Neural Network"

# ╔═╡ 6a5b57b0-5b62-11eb-062b-53cc050c08d5
md"### Principles"

# ╔═╡ 7c3956e4-5b62-11eb-3970-1772008526e5
md"
The main components of a (vanilla) artificial neural network are the following:  
  1. Initialisation of the model parameters (weights, biases)
  1. Forward pass with current model parameters
  1. Calculate the cost based on current predictions 
  1. Calculate the gradient of the parameters w.r.t the cost function using back propagation
  1. Update the model parameters, using gradient descent

"

# ╔═╡ eeb33b76-5b63-11eb-30d3-b3aba884c65a
md"#### 0. Preparation"

# ╔═╡ 2eb47b46-5b63-11eb-1304-edba9ee403db
md"#### 1 - Initialization"

# ╔═╡ 4123b65c-5b63-11eb-262a-c3ab589a6c5d
function init_ann_model(layer_dims::Vector{T};
                        seed=42, init=:He, DType=Float32)::Dict{String, Matrix{DType}} where T <: Integer
  parms = Dict{String, Matrix{DType}}()

  for l ∈ 2:length(layer_dims)
    key_w, key_b = string("w", l-1), string("b", l-1)
    parms[key_w] = rand(StableRNG(seed), layer_dims[l], layer_dims[l-1])
    if init == :He
      parms[key_w] *= √(2 / layer_dims[l-1])
    end
    parms[key_b] = zeros(layer_dims[l], 1)
  end

  parms
end

# ╔═╡ b21ae628-5b63-11eb-3316-a5a0d7ebf70c
begin
  layer_dims = [5, 4, 3]
  parms = init_ann_model(layer_dims; seed=70)


  @test size(parms["w1"]) == (layer_dims[2], layer_dims[1])
  @test parms["w1"] ≈ Float32[ 0.318851   0.439791   0.244843   0.56474   0.0140048;
                               0.401535   0.0771849  0.0814277  0.517576  0.399674;
                               0.431036   0.224612   0.225044   0.627921  0.224198;
                               0.0359117  0.136611   0.598639   0.107276  0.503642 ]

  @test size(parms["w2"]) == (layer_dims[3], layer_dims[2])
  @test parms["w2"] ≈ Float32[ 0.356487  0.0401505  0.251124  0.0910389;
                               0.44893   0.491702   0.152735  0.251607;
                               0.481913  0.0862954  0.273743  0.669299 ]

  @test size(parms["b1"]) == (layer_dims[2], 1)
  @test parms["b1"] ≈ Float32[0.0; 0.0; 0.0; 0.0]

  @test size(parms["b2"]) == (layer_dims[3], 1)
  @test parms["b2"] ≈ Float32[0.0; 0.0; 0.0]
end

# ╔═╡ 0dea5ad8-5b64-11eb-0800-83ced477bbcf
begin
  println("w1: $(parms["w1"])")
  parms["w2"]
	
  println(parms["b1"])
  println(parms["b2"])
	
  # print on the terminal...
end

# ╔═╡ 172012c4-5b63-11eb-305b-95ea2a5ae7da
md"#### 2. Forward Propagation"

# ╔═╡ 5dc06428-5b62-11eb-2eda-8bb1bd597af2
md"
Now that we have initialized our parameters, we will do the forward propagation module. We will complete three functions in this order:

    LINEAR
    LINEAR -> ACTIVATION where ACTIVATION will be either ReLU or Sigmoid.
    [LINEAR -> RELU] × (L-1) -> LINEAR -> SIGMOID (whole model)

The linear forward module (vectorized over all the examples) computes the following equations:

$𝑍^{[𝑙]} = 𝑊^{[𝑙]} \times 𝐴^{[𝑙−1]} + 𝑏^{[𝑙]}$    
where $𝐴^{[0]} = 𝑋$

"

# ╔═╡ 59f7fa6e-5b66-11eb-07ab-775ff51dd945
function linear_forward(a, w, b)
  z = (w * a) .+ b
  cache = (a, w, b)

  @assert size(z) ≡ (size(w, 1), size(a, 2))

  return (Z=z, Cache=cache)
end

# ╔═╡ 2b433378-5b66-11eb-069a-4d29ee1187ac
function sigmoid_afn(z)
  a = 1. ./ (1. .+ exp.(.-z))
  return (a=a, z=z)
end

# ╔═╡ 529b1f78-5b67-11eb-3a7d-e5b42b28e4b9
function relu_afn(z)
  a = max.(0.0, z)
  return (a=a, z=z)
end

# ╔═╡ 4479bdf0-5b66-11eb-3d18-47a5c179eaef
function linear_forward_activation(aₚ, w, b; activation_fn=relu_afn)
  # @assert Symbol(activation_fn) ∈ ACTIVATION_FN "Expecting $(Symbol(activation_fn)) to be in $(ACTIVATION_FN)"

  (z, linear_cache) = linear_forward(aₚ, w, b)
  (a, activ_cache) = activation_fn(z)

  @assert size(a) ≡ (size(w, 1), size(a, 2))
  (a, (Linear_Step_Cache=linear_cache,
       Activation_Step_Cache=activ_cache))
end

# ╔═╡ 7f3dd108-5b67-11eb-1053-65da9401bbb4
begin
  #  a = rand(StableRNG(70), 5, 3) # 5×3 Array{Float64,2}:
  a = Float32[ 0.504148   0.12204   0.355826  0.169619;
               0.634883   0.355143  0.946531  0.0221436;
               0.681527   0.216     0.892933  0.631941;
               0.0567814  0.387131  0.81836   0.354488;
               0.695371   0.128749  0.99283   0.796328 ]


  ntuple = linear_forward_activation(a, parms["w1"], parms["b1"]; activation_fn=sigmoid_afn)

  @test size(ntuple[1]) == (4, 4)
  @test ntuple[1] ≈ Float32[0.656703  0.61501   0.772841  0.605848;
                            0.648908  0.585606  0.751946  0.650905;
                            0.669259  0.611337  0.786403  0.650543;
                            0.704566  0.571648  0.779791  0.695617 ]

end

# ╔═╡ cfd413e0-5b74-11eb-2612-25b1fcc2f06c
md"""
For more convenience when implementing the $L$-layer Neural Net, we will need a function that replicates the previous one (`linear_activation_forward` with RELU) $L-1$ times, then follows that with one `linear_forward_activation` with SIGMOID.


$(PlutoUI.LocalResource("./images/model_architecture.png"))

"""

# ╔═╡ 7b38ea92-5b72-11eb-2965-c194d2f4b6fb
function forward_pass(x, parms)
  a = x
  l_len = length(parms) ÷ 2
  meta_cache = []

  ## forward propagate until penultimate layer (last layer before output)
  for l ∈ 1:l_len-1
    aₚ = a
    key_w, key_b = string("w", l), string("b", l)
    a, cache = linear_forward_activation(aₚ, parms[key_w], parms[key_b])  # using relu
    push!(meta_cache, cache)
  end

  ## make predictions with output layer
  key_w, key_b = string("w", l_len), string("b", l_len)
  ŷ, cache = linear_forward_activation(a, parms[key_w], parms[key_b]; activation_fn=sigmoid_afn)
  push!(meta_cache, cache)

  return (ŷ, meta_cache)
end

# ╔═╡ bb359e48-5b67-11eb-051e-c307d753acbf
md"#### 3. Cost"

# ╔═╡ 197d7b88-5b68-11eb-3777-29fe57c48ebc
md"
Now let's compute the cost to check if our model is actually learning.
We will use the cross-entropy cost $J$, using the following formula: 

$$-\frac{1}{m} \sum\limits_{i = 1}^{m} (y^{(i)}\log\left(a^{[L] (i)}\right) + (1-y^{(i)})\log\left(1- a^{[L](i)}\right)) \tag{7}$$

"

# ╔═╡ 0ba466ec-5b69-11eb-020b-5bb9d683f66b
function cost_fn(ŷ, y)
  m = size(y, 2)
  ϵ = eps(1.0)

  ŷₙ = max.(ŷ, ϵ)
  ŷₙ = min.(ŷₙ, 1 - ϵ)

  - sum(y .* log.(ŷₙ) + (1 .- y) .* log.(1 .- ŷₙ)) / m
end

# ╔═╡ 96941fa6-5b67-11eb-201c-bbcac11a9cb6
md"""#### Backward Propagation

Back propagation is used to calculate the gradient of the loss function with respect to the parameters.

$(PlutoUI.LocalResource("./images/backprop.png"))

"""

# ╔═╡ 0f88b984-5b6e-11eb-3617-092f82ad69e5
md"""
Figure 1: Forward and Backward propagation for LINEAR->RELU->LINEAR->SIGMOID  

The purple blocks represent the forward propagation, and the red blocks represent the backward propagation. 
"""

# ╔═╡ 82d03232-5b69-11eb-3e64-3fb43a0c0174
md"
Now, similar to forward propagation, we are going to build the backward propagation in three steps:
  - LINEAR backward
  - LINEAR -> ACTIVATION backward where ACTIVATION computes the derivative of either the ReLU or sigmoid activation
  - [LINEAR -> RELU] $\times$ (L-1) -> LINEAR -> SIGMOID backward (whole model)
"

# ╔═╡ ba022c96-5b6f-11eb-1c61-1facb55fe71a
md"""
**Linear backward**

For layer $l$, the linear part is: 
$Z^{[l]} = W^{[l]} A^{[l-1]} + b^{[l]}$ (followed by an activation).

Suppose you have already calculated the derivative 
$dZ^{[l]} = \frac{\partial \mathcal{L} }{\partial Z^{[l]}}$.   

You want to get $(dW^{[l]}, db^{[l]} dA^{[l-1]})$.


$(PlutoUI.LocalResource("./images/linearback.png"))  

"""

# ╔═╡ da0b99f6-5b6e-11eb-2d31-5730c021febf
md"""

The three outputs $(dW^{[l]}, db^{[l]}, dA^{[l]})$ are computed using the input $dZ^{[l]}$ . Here are the formulas you need:

\$$ dW^{[l]} = \frac{\partial \mathcal{L}}{\partial W^{[l]}} = \frac{1}{m} \partial Z^{[l]} A^{[l-1] T} \$$

\$$ db^{[l]} = \frac{\partial \mathcal{L}}{\partial b^{[l]}} = \frac{1}{m} \sum_{i= 1}^{m} \partial Z^{[l]\(i\)} \$$


\$$ dA^{[l-1]} = \frac{\partial \mathcal{L}}{\partial A^{[l-1]}} = W^{[l] T} \partial Z^{[l]} \$$

"""

# ╔═╡ 6f17b8e4-5b6b-11eb-324d-1123b09c961b
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

# ╔═╡ 662557ca-5b69-11eb-0efe-b314df63c37a
function linear_backward_activation(∂a, cache; activation_fn=relu_afn)
  # @assert Symbol(activation_fn) ∈ ACTIVATION_FN "Expecting $(Symbol(activation_fn)) to be in $(ACTIVATION_FN)"

  linear_cache, activ_cache = cache
  ∂z = getfield(@__MODULE__, Symbol(string("der_", activation_fn)))(∂a, activ_cache)

  (∂w, ∂b, ∂aₚ) = linear_backward(∂z, linear_cache)

  return (∂w, ∂b, ∂aₚ)
end


# ╔═╡ 9216357c-5b67-11eb-3530-1335910b4912
function der_sigmoid_afn(∂a, act_cache)
  s = sigmoid_afn(act_cache).a
  ∂z = ∂a .* s .* (1. .- s)
  @assert size(∂z) == size(act_cache)
  return ∂z
end

# ╔═╡ 5412f372-5b72-11eb-2973-4714d46e176d
function der_relu_afn(∂a, act_cache)
  ∂a .* (act_cache .> 0.0)
end

# ╔═╡ a5bd74fe-5b72-11eb-1dff-efcebac05c50
md"""
when we implemented the `forward_pass` function we stored a cache which contains (X,W,b, and z). 
In the back propagation module, we will use those variables to compute the gradients. In the `backward_pass` function, we will iterate through all the hidden layers backward, starting from layer $L$. On each step, you will use the cached values for layer $l$ to backpropagate through layer $l$.  


$(PlutoUI.LocalResource("./images/nm_backward.png")) 

"""

# ╔═╡ 38bdd950-5b74-11eb-1c06-6b75d64cf86e
md"""
**Initializing backpropagation**:

To backpropagate through this network, we know that the output is, 
$A^{[L]} = \sigma(Z^{[L]})$. In our code we need to compute 
`dAL` $= \frac{\partial \mathcal{L}}{\partial A^{[L]}}$.



```julia
∂aₗ = - - (y ./ aₗ) .+ (1 .- y) ./ (1 .- aₗ) # derivative of cost with respect to AL
```

We can then use this post-activation gradient `∂aₗ` to keep going backward. As seen in figure above, we can now feed in `∂aₗ` into the LINEAR->SIGMOID backward function we implemented (which will use the cached values stored by the `forward_pass` function).

After that, we will have to use a `for` loop to iterate through all the other layers using the LINEAR->RELU backward function. We will store each ∂a, ∂W, and ∂b in the ∇ dictionary. To do so, use this formula : 

$ ∇[string("∂W", l)] = dW^{[l]}$

"""

# ╔═╡ 678f77ae-5b72-11eb-3844-efc961e74b0a
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

# ╔═╡ Cell order:
# ╟─b973db3a-5b60-11eb-1e10-0f1558cff343
# ╟─6a5b57b0-5b62-11eb-062b-53cc050c08d5
# ╟─7c3956e4-5b62-11eb-3970-1772008526e5
# ╟─eeb33b76-5b63-11eb-30d3-b3aba884c65a
# ╠═ab815d22-5b63-11eb-2f45-81b70732b6b2
# ╠═38958a82-5b64-11eb-22dc-37be1aaa9056
# ╟─2eb47b46-5b63-11eb-1304-edba9ee403db
# ╠═4123b65c-5b63-11eb-262a-c3ab589a6c5d
# ╠═b21ae628-5b63-11eb-3316-a5a0d7ebf70c
# ╠═0dea5ad8-5b64-11eb-0800-83ced477bbcf
# ╟─172012c4-5b63-11eb-305b-95ea2a5ae7da
# ╟─5dc06428-5b62-11eb-2eda-8bb1bd597af2
# ╠═59f7fa6e-5b66-11eb-07ab-775ff51dd945
# ╠═4479bdf0-5b66-11eb-3d18-47a5c179eaef
# ╠═2b433378-5b66-11eb-069a-4d29ee1187ac
# ╠═529b1f78-5b67-11eb-3a7d-e5b42b28e4b9
# ╠═7f3dd108-5b67-11eb-1053-65da9401bbb4
# ╟─cfd413e0-5b74-11eb-2612-25b1fcc2f06c
# ╠═7b38ea92-5b72-11eb-2965-c194d2f4b6fb
# ╟─bb359e48-5b67-11eb-051e-c307d753acbf
# ╟─197d7b88-5b68-11eb-3777-29fe57c48ebc
# ╠═0ba466ec-5b69-11eb-020b-5bb9d683f66b
# ╠═1ca31664-5b6e-11eb-05e4-f3f15fb7abab
# ╟─96941fa6-5b67-11eb-201c-bbcac11a9cb6
# ╟─0f88b984-5b6e-11eb-3617-092f82ad69e5
# ╟─82d03232-5b69-11eb-3e64-3fb43a0c0174
# ╠═ba022c96-5b6f-11eb-1c61-1facb55fe71a
# ╟─da0b99f6-5b6e-11eb-2d31-5730c021febf
# ╠═6f17b8e4-5b6b-11eb-324d-1123b09c961b
# ╠═662557ca-5b69-11eb-0efe-b314df63c37a
# ╠═9216357c-5b67-11eb-3530-1335910b4912
# ╠═5412f372-5b72-11eb-2973-4714d46e176d
# ╟─a5bd74fe-5b72-11eb-1dff-efcebac05c50
# ╟─38bdd950-5b74-11eb-1c06-6b75d64cf86e
# ╠═678f77ae-5b72-11eb-3844-efc961e74b0a
