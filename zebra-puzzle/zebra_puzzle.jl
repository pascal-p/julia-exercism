### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# ╔═╡ 7c571028-6e66-11eb-00ba-6bc2659d8037
begin
	using Test
	using PlutoUI
end

# ╔═╡ 20286d52-6e62-11eb-0bb9-ab105212b970
md"""
## Zebra Puzzle

Given the following facts:

1. There are five houses.
1. The Englisman lives in the red house.
1. The Spaniard owns a dog.
1. Coffee is drunk in the green house.
1. The Ukrainian drinks tea.
1. The green house is immediately to the right of the ivory house.
1. The Old Gold smoker owns snails.
1. Kools are smoked in the yellow house.
1. Milk is drunk in the middle house.
1. The Norwegian lives in the first house.
1. The man who smokes the Chesterfields lives in the house next to the man with the fox.
1. The Lucky Strike smoker drinks orange juice.
1. The Japanese smokes Parliaments.
1. The Norwegian lives next to the blue house.


Who drinks water? who owns the zebra?

In the interest of clarity, it must be added that each of the five houses is painted in a different color, and their inhabitants are of different national extractions, own different pets, drink different beverages and smoke different brands of American cigarets.

In statement 6, *right* means *your* right.
"""

# ╔═╡ b93b798e-6e69-11eb-2ce0-51790820e04f


# ╔═╡ 1a019484-6e66-11eb-29ce-01fc3c705296
const VVT{T} = Vector{Vector{T}} where T 

# ╔═╡ b6ba1374-6e65-11eb-3ea7-3fd33ea007f2
function prepend(x::T, vl::VVT{T}) where T
	nl = []
	for l ∈ vl
		push!(nl, [x, l...])
	end
	nl
end

# ╔═╡ 7098569a-6e64-11eb-2e39-35199e6209a0
# (all) permutations of a list

function permutations(lst::Vector{T})::VVT{T} where T <: Any 
	length(lst) == 1 && return [lst]
	length(lst) == 2 && return [lst, reverse(lst)]
	
	# |lst| > 2
	nperms = []
	for x ∈ lst
		ns = prepend(x, permutations(filter(y -> y != x, lst)))
		nperms = [nperms..., ns...]# push!(nperms, ns)
	end
	
	nperms
end

# ╔═╡ 37c57a7a-6e65-11eb-2242-a9fd1ccac3b7
@test prepend(1, [[2, 3], [3, 2]]) == Any[Int[1, 2, 3], Int[1, 3, 2]] 

# ╔═╡ 0c60f022-6e66-11eb-3f7c-0da3ac734e84
@test prepend(2, [[1, 3, 4], [1, 4, 3], [3, 1, 4], 
		[3, 4, 1], [4, 1, 3], [4, 3, 1]]) == Any[Int[2, 1, 3, 4], Int[2, 1, 4, 3],
		Int[2, 3, 1, 4], Int[2, 3, 4, 1], Int[2, 4, 1, 3], Int[2, 4, 3, 1]
	]

# ╔═╡ 0a8513d8-6e65-11eb-1af9-d3c74b54284e
permutations([1, 2])

# ╔═╡ 1419736a-6e65-11eb-1481-6f4f867f40fa
permutations([1, 2, 3])

# ╔═╡ 9eb9bb82-6e63-11eb-3a0b-4d4e52d43260
function make_constraints(fn::Function, s::String)::VVT
	lst = split(s) |>
	    a -> map(x -> String(x), a) |>
		permutations
	filter(fn, lst)
end

# ╔═╡ 5f4680d4-6e68-11eb-16d5-83ab3e15ef02
# rule 10. The Norwegian lives in the first house (x[1])

begin

nationalities = make_constraints(x -> "Norwegian" == x[1], 
		"Spaniard English Ukrainian Norwegian Japanese")
@test length(nationalities) == 24

with_terminal() do
	for x ∈ nationalities
		println(x)
	end
end
	
end

# ╔═╡ 23f9a42e-6e69-11eb-03e0-d56f8922441b
# rule 9. Milk is drunk in the middle house (x[3])
begin

drinks = make_constraints(x -> "Milk" == x[3],
		"Water Coffee Milk Tea Orange_Juice")
@test length(drinks) == 24

with_terminal() do
	for x ∈ drinks
		println(x)
	end
end
	
end

# ╔═╡ 7d8efc14-6e69-11eb-03e6-152ce2442085
# rule 6. The green house is immediately to the right of the ivory house.
begin
	
colors = make_constraints(x -> findfirst(c -> c == "Green", x) - 
		findfirst(c -> c == "Ivory", x) == 1, 
		"Ivory Green Red Blue Yellow")
@test length(colors) == 24
	
with_terminal() do
	for cs ∈ colors
		println(cs)
	end
end
	
end	

# ╔═╡ 8e5aea72-6e6b-11eb-0c77-edb583e70372
begin
	pets = make_constraints(x -> true, "Fox Horse Snails Dog Zebra")
	@test length(pets) == 120
end

# ╔═╡ bccadce6-6e95-11eb-252a-f53c0e81032a
pets[1:5]

# ╔═╡ 209afe12-6e6c-11eb-0c90-81b34f138dad
begin
	smokes = make_constraints(x -> true, 
		"Kools Chesterfield Old_Gold Lucky_Strike Parliaments") 
	@test length(smokes) == 120
end

# ╔═╡ ce943346-6e95-11eb-2bfd-d981988f3b70
smokes[1:3]

# ╔═╡ 068673f6-6e6c-11eb-07f6-c33380223cff
begin

function eq(x::T1, xs::Vector{T1}, y::T2, ys::Vector{T2})::Bool where {T1, T2}
  findfirst(xᵢ -> xᵢ == x, xs) == findfirst(yᵢ -> yᵢ == y, ys)
end
  
function adj(x::T1, xs::Vector{T1}, y::T2, ys::Vector{T2})::Bool where {T1, T2}
  abs(findfirst(xᵢ -> xᵢ == x, xs) - findfirst(yᵢ -> yᵢ == y, ys)) == 1
end
		
print_sol(n::Int, nat, pet, col, drink, smoke) = 
  println("$(n). $nat, $pet, $col, $drink, $smoke")
end

# ╔═╡ e6e1a144-6e8f-11eb-07c8-11f224743966
typeof(nationalities[1])

# ╔═╡ 28b9b840-6e74-11eb-26e2-a5cbfe72c63a
with_terminal() do

for ns ∈ nationalities, cs ∈ colors
  #
  # 2. The Englishman lives in the red house.
  # 15. The Norwegian lives next to the blue house.
  #	
  if eq("Red", cs, "English", ns) && adj("Norwegian", ns, "Blue", cs)
	println("1. TRY: $(ns) / $(cs)")
	for ds ∈ drinks
	  #
	  # 4. Coffee is drunk in the green house.
	  # 5. The Ukrainian drinks tea.
	  #
	  if eq("Coffee", ds, "Green", cs) && eq("Ukrainian", ns, "Tea", ds)
		for s ∈ smokes
		  #
		  # 8. Kools are smoked in the yellow house.
		  # 13. The Lucky Strike smoker drinks orange juice.
		  # 14. The Japanese smokes Parliaments.
		  #
		  if eq("Kools", s, "Yellow", cs) && 
		    eq("Lucky_Strike", s, "Orange_Juice", ds) &&
			eq("Parliaments", s, "Japanese", ns)
							
			println("2. TRY: $(ns) / $(cs) / $(ds) / s: $(s)")
							
			for ps ∈ pets
			  #
			  # 3. The Spaniard owns the dog.
			  # 7. The Old Gold smoker owns snails.
			  # 11. The man who smokes Chesterfields lives in the house next to the man with the fox.
			  # 12. Kools are smoked in the house next to the house where the horse is kept.
			  if eq("Spaniard", ns, "Dog", ps) &&
				eq("Old_Gold", s, "Snails", ps) &&
				adj("Chesterfields", s, "Fox", ps) &&
				adj("Kools", s, "Horse", ps)										
				  println("Zebra is owned by ", ns[findfirst(p -> p == "Zebra", ps)])
                  println("Houses:")
				  for hnum ∈ 1:5
				    print_sol(hnum, ns[hnum], ps[hnum], cs[hnum], ds[hnum], s[hnum])
				  end
			  end
			end
		  end
	    end
	  end
    end
  end
end

end

# ╔═╡ 4d6657a6-6e98-11eb-2609-7b0bf0e8a231


# ╔═╡ 4a112e28-6e98-11eb-2350-21c4a84d1775


# ╔═╡ b9d72476-6e96-11eb-0d4b-0f9ad022f4b4


# ╔═╡ Cell order:
# ╟─20286d52-6e62-11eb-0bb9-ab105212b970
# ╠═b93b798e-6e69-11eb-2ce0-51790820e04f
# ╠═1a019484-6e66-11eb-29ce-01fc3c705296
# ╠═7098569a-6e64-11eb-2e39-35199e6209a0
# ╠═b6ba1374-6e65-11eb-3ea7-3fd33ea007f2
# ╠═7c571028-6e66-11eb-00ba-6bc2659d8037
# ╠═37c57a7a-6e65-11eb-2242-a9fd1ccac3b7
# ╠═0c60f022-6e66-11eb-3f7c-0da3ac734e84
# ╠═0a8513d8-6e65-11eb-1af9-d3c74b54284e
# ╠═1419736a-6e65-11eb-1481-6f4f867f40fa
# ╠═9eb9bb82-6e63-11eb-3a0b-4d4e52d43260
# ╠═5f4680d4-6e68-11eb-16d5-83ab3e15ef02
# ╠═23f9a42e-6e69-11eb-03e0-d56f8922441b
# ╠═7d8efc14-6e69-11eb-03e6-152ce2442085
# ╠═8e5aea72-6e6b-11eb-0c77-edb583e70372
# ╠═bccadce6-6e95-11eb-252a-f53c0e81032a
# ╠═209afe12-6e6c-11eb-0c90-81b34f138dad
# ╠═ce943346-6e95-11eb-2bfd-d981988f3b70
# ╠═068673f6-6e6c-11eb-07f6-c33380223cff
# ╠═e6e1a144-6e8f-11eb-07c8-11f224743966
# ╠═28b9b840-6e74-11eb-26e2-a5cbfe72c63a
# ╠═4d6657a6-6e98-11eb-2609-7b0bf0e8a231
# ╠═4a112e28-6e98-11eb-2350-21c4a84d1775
# ╠═b9d72476-6e96-11eb-0d4b-0f9ad022f4b4
