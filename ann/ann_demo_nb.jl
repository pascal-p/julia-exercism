### A Pluto.jl notebook ###
# v0.12.18

using Markdown
using InteractiveUtils

# ╔═╡ 9cad7ae6-5b75-11eb-1610-d75de1333fb2
begin
  push!(LOAD_PATH, "./src")
  using YA_ANN

  using Plots
  using MLJBase
  using StableRNGs # Seeding generator for reproducibility
end

# ╔═╡ 7688a17e-5b75-11eb-25c5-f17d8bd018cf
md"### ANN demo"

# ╔═╡ b75c4746-5b75-11eb-1073-ad7fafa72cfc
begin
## Generate fake data
x, y = make_blobs(10_000, 3; centers=2, as_table=false, rng=2020, eltype=Float32)

x = Matrix{Float32}(x')
y = reshape(y, (1, size(x, 2)));

f(x) = x == 2 ? Float32(0.) : Float32(x)
y₂ = f.(y);
end

# ╔═╡ c1829b62-5b75-11eb-0aff-f9402290a757
begin
## Input dimensions
input_dim = size(x, 1);

# Train the model
nn_results = train_ann_model([input_dim, 5, 3, 1], x, y₂;
                             η=0.01, epochs=50, seed=1, verbose=true);

end

# ╔═╡ e2721a0a-5b75-11eb-087b-e32051c60af4
## Plot accuracy per iteration
p1 = plot(nn_results.accuracy,
         label="Accuracy",
         xlabel="Number of iterations",
         ylabel="Accuracy as %",
         title="Accuracy at each iteration");


# ╔═╡ e622c97e-5b75-11eb-0387-452cb26410ea
## Plot cost per iteration
p2 = plot(nn_results.cost,
         label="Cost",
         xlabel="Number of iterations",
         ylabel="Cost (J)",
         color="red",
         title="Cost at each iteration");

# ╔═╡ e5b1745e-5b75-11eb-2068-ab37bd498269
## Combine accuracy and cost plots
plot(p1, p2, layout = (2, 1), size=(800, 600))

# ╔═╡ Cell order:
# ╠═7688a17e-5b75-11eb-25c5-f17d8bd018cf
# ╠═9cad7ae6-5b75-11eb-1610-d75de1333fb2
# ╠═b75c4746-5b75-11eb-1073-ad7fafa72cfc
# ╠═c1829b62-5b75-11eb-0aff-f9402290a757
# ╠═e2721a0a-5b75-11eb-087b-e32051c60af4
# ╠═e622c97e-5b75-11eb-0387-452cb26410ea
# ╠═e5b1745e-5b75-11eb-2068-ab37bd498269
