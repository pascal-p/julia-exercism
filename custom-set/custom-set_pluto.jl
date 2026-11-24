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

# ╔═╡ 66666666-6666-4666-8666-666666666601
begin
    import Pkg
    Pkg.activate(dirname(@__DIR__))
    using Test
    using PlutoUI
end

# ╔═╡ 66666666-6666-4666-8666-666666666602
md"""
# Custom Set

A custom `AbstractSet{T}` backed by `Dict{T,Nothing}` implementing `isempty`, `length`, `∈`, `==`, `issubset`, `disjoint`, `push!`, `copy`, `intersect`/`intersect!`, `complement`/`complement!`, `union`/`union!`, and `Base.show`.
"""

# ╔═╡ 66666666-6666-4666-8666-666666666603
md"""
## Solution (`custom-set.jl`)
"""

# ╔═╡ 66666666-6666-4666-8666-666666666604
include("custom-set.jl")

# ╔═╡ 66666666-6666-4666-8666-666666666605
md"""
## Interactive Explorer
"""

# ╔═╡ 66666666-6666-4666-8666-666666666606
@bind max_a PlutoUI.Slider(0:8; default = 4, show_value = true)

# ╔═╡ 66666666-6666-4666-8666-666666666607
@bind min_b PlutoUI.Slider(1:9; default = 3, show_value = true)

# ╔═╡ 66666666-6666-4666-8666-666666666608
begin
    s1 = CustomSet(collect(1:max_a))
    s2 = CustomSet(collect(min_b:6))
    md"""
    - **`s1`:** `$(s1)` | **`s2`:** `$(s2)`
    - **`s1 ∩ s2`:** `$(s1 ∩ s2)`
    - **`s1 ∪ s2`:** `$(s1 ∪ s2)`
    - **`complement(s1, s2)`:** `$(complement(s1, s2))`
    - **`disjoint(s1, s2)`:** `$(disjoint(s1, s2))` | **`issubset(s1, s2)`:** `$(issubset(s1, s2))`
    """
end

# ╔═╡ 66666666-6666-4666-8666-666666666609
md"""
## Test Suite
"""

# ╔═╡ 66666666-6666-4666-8666-666666666610
begin
    @testset "core & edge-case checks" begin
        @test CustomSet <: AbstractSet
        @test disjoint(CustomSet([1]), CustomSet(Int[]))
        @test CustomSet([1 + 2im, 3 + 4im]) == CustomSet([3 + 4im, 1 + 2im])
        @test (CustomSet([1, 2]) ∩ CustomSet([2, 3])) == CustomSet([2])
        @test (CustomSet([1, 2]) ∪ CustomSet([2, 3])) == CustomSet([1, 2, 3])
        @test union(CustomSet([1]), CustomSet([2.5])) == CustomSet([1, 2.5])
    end
end

# ╔═╡ Cell order:
# ╠═66666666-6666-4666-8666-666666666601
# ╟─66666666-6666-4666-8666-666666666602
# ╟─66666666-6666-4666-8666-666666666603
# ╠═66666666-6666-4666-8666-666666666604
# ╟─66666666-6666-4666-8666-666666666605
# ╠═66666666-6666-4666-8666-666666666606
# ╠═66666666-6666-4666-8666-666666666607
# ╠═66666666-6666-4666-8666-666666666608
# ╟─66666666-6666-4666-8666-666666666609
# ╠═66666666-6666-4666-8666-666666666610
