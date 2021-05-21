#
# from https://towardsdatascience.com/how-to-build-an-artificial-neural-network-from-scratch-in-julia-c839219b3ef8
#

using Pkg; Pkg.activate("Exercism_env", shared=true)

push!(LOAD_PATH, "./src")
using YA_ANN

using Plots
using MLJBase
using StableRNGs # Seeding generator for reproducibility


## Generate fake data
x, y = make_blobs(10_000, 3; centers=2, as_table=false, rng=2020, eltype=Float32)

x = Matrix{Float32}(x')
y = reshape(y, (1, size(x, 2)));

f(x) = x == 2 ? Float32(0.) : Float32(x)
y₂ = f.(y);

## Input dimensions
input_dim = size(x, 1);

# Train the model
nn_results = train_ann_model([input_dim, 5, 3, 1], x, y₂;
                             η=0.01, epochs=50, seed=1, verbose=true);

# println(nn_results)

## Plot accuracy per iteration
p1 = plot(nn_results.accuracy,
         label="Accuracy",
         xlabel="Number of iterations",
         ylabel="Accuracy as %",
         title="Accuracy at each iteration");

## Plot cost per iteration
p2 = plot(nn_results.cost,
         label="Cost",
         xlabel="Number of iterations",
         ylabel="Cost (J)",
         color="red",
         title="Cost at each iteration");

## Combine accuracy and cost plots
plot(p1, p2, layout = (2, 1), size=(800, 600))
