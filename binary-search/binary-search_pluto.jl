### A Pluto.jl notebook ###
# v0.20.4

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound values a default value.
macro bind(def, element)
    #! format: off
    return quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
    #! format: on
end

# ╔═╡ 55555555-5555-4555-8555-555555555501
begin
    import Pkg
    Pkg.activate(dirname(@__DIR__))
    using Test
    using PlutoUI
end

# ╔═╡ 55555555-5555-4555-8555-555555555502
md"""
# Binary Search

Search a sorted `AbstractVector` in `O(log n)` time, returning the matching index range (or an empty range `l:(l-1)` at the insertion point if not found).
Supports `by`, `lt`, `rev`, and `all` (`O(log n)` `lower_bound` / `upper_bound`).
"""

# ╔═╡ 55555555-5555-4555-8555-555555555503
md"""
## Solution (`binary-search.jl`)
"""

# ╔═╡ 55555555-5555-4555-8555-555555555504
include("binary-search.jl")

# ╔═╡ 55555555-5555-4555-8555-555555555505
md"""
## Interactive Explorer
"""

# ╔═╡ 55555555-5555-4555-8555-555555555506
@bind target PlutoUI.Slider(0:12; default = 3, show_value = true)

# ╔═╡ 55555555-5555-4555-8555-555555555507
@bind find_all PlutoUI.CheckBox(default = true)

# ╔═╡ 55555555-5555-4555-8555-555555555508
@bind reversed PlutoUI.CheckBox(default = false)

# ╔═╡ 55555555-5555-4555-8555-555555555509
begin
    sample = reversed ? [11, 9, 8, 6, 3, 3, 3, 2, 1] : [1, 2, 3, 3, 3, 6, 8, 9, 11]
    res = binarysearch(sample, target; rev = reversed, all = find_all)
    md"""
    - **Array:** `$(sample)` (`rev = $(reversed)`)
    - **Search for `$(target)`** (`all = $(find_all)`): **`$(res)`** (`isempty = $(isempty(res))`)
    """
end

# ╔═╡ 55555555-5555-4555-8555-555555555510
md"""
## Test Suite
"""

# ╔═╡ 55555555-5555-4555-8555-555555555511
begin
    @testset "core & bonus checks" begin
        @test binarysearch([1, 3, 4, 6, 8, 9, 11], 6) == 4:4
        @test binarysearch([1, 3, 4, 6, 8, 9, 11], 5) == 4:3
        @test binarysearch([1, 2, 2, 2, 3, 4], 2; all = true) == 2:4
        @test binarysearch([11, 9, 8, 6, 4, 3, 1], 6; rev = true) == 4:4
        @test binarysearch([1.1, 2.9, 4.4, 5.5, 8.1, 9.0, 10.8], 6; by = round) == 4:4
        @test binarysearch([11, 9, 8, 6, 4, 3, 1], 7; lt = >) == 4:3
        @test binarysearch([], 1; rev = true) == 1:0
    end
end

# ╔═╡ Cell order:
# ╠═55555555-5555-4555-8555-555555555501
# ╟─55555555-5555-4555-8555-555555555502
# ╟─55555555-5555-4555-8555-555555555503
# ╠═55555555-5555-4555-8555-555555555504
# ╟─55555555-5555-4555-8555-555555555505
# ╠═55555555-5555-4555-8555-555555555506
# ╠═55555555-5555-4555-8555-555555555507
# ╠═55555555-5555-4555-8555-555555555508
# ╠═55555555-5555-4555-8555-555555555509
# ╟─55555555-5555-4555-8555-555555555510
# ╠═55555555-5555-4555-8555-555555555511
