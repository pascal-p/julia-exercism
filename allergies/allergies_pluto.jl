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

# ╔═╡ 33333333-3333-4333-8333-333333333301
begin
    import Pkg
    Pkg.activate(dirname(@__DIR__))
    using Test
    using PlutoUI
end

# ╔═╡ 33333333-3333-4333-8333-333333333302
md"""
# Allergies

Given a person's allergy score, determine whether or not they're allergic to a given item, and their full list of allergies.

Tested items and their values:
- `eggs` (`1`), `peanuts` (`2`), `shellfish` (`4`), `strawberries` (`8`)
- `tomatoes` (`16`), `chocolate` (`32`), `pollen` (`64`), `cats` (`128`)

Unknown allergen bits (`256`, `512`, `1024`, …) are ignored.
"""

# ╔═╡ 33333333-3333-4333-8333-333333333303
md"""
## Solution (`allergies.jl`)
"""

# ╔═╡ 33333333-3333-4333-8333-333333333304
include("allergies.jl")

# ╔═╡ 33333333-3333-4333-8333-333333333305
md"""
## Interactive Explorer
"""

# ╔═╡ 33333333-3333-4333-8333-333333333306
@bind score PlutoUI.Slider(0:511; default = 34, show_value = true)

# ╔═╡ 33333333-3333-4333-8333-333333333307
begin
    list = sort!(collect(allergy_list(score)))
    md"""
    - **Score:** `$(score)` (`0b$(string(score; base = 2, pad = 9))`)
    - **Allergies:** `$(isempty(list) ? "(none)" : join(list, ", "))`
    """
end

# ╔═╡ 33333333-3333-4333-8333-333333333308
md"""
## Test Suite
"""

# ╔═╡ 33333333-3333-4333-8333-333333333309
begin
    @testset "testing for single allergies" begin
        @test !allergic_to(0, "eggs")
        @test allergic_to(1, "eggs")
        @test allergic_to(3, "eggs")
        @test allergic_to(255, "eggs")
        @test allergic_to(257, "eggs")
        @test !allergic_to(256, "cats")
    end

    @testset "testing the allergy_list" begin
        @test allergy_list(0) == Set{String}()
        @test allergy_list(34) == Set(["peanuts", "chocolate"])
        @test allergy_list(256) == Set{String}()
        @test allergy_list(257) == Set(["eggs"])
        @test allergy_list(509) == Set([
            "eggs",
            "shellfish",
            "strawberries",
            "tomatoes",
            "chocolate",
            "pollen",
            "cats",
        ])
    end
end

# ╔═╡ Cell order:
# ╠═33333333-3333-4333-8333-333333333301
# ╟─33333333-3333-4333-8333-333333333302
# ╟─33333333-3333-4333-8333-333333333303
# ╠═33333333-3333-4333-8333-333333333304
# ╟─33333333-3333-4333-8333-333333333305
# ╠═33333333-3333-4333-8333-333333333306
# ╠═33333333-3333-4333-8333-333333333307
# ╟─33333333-3333-4333-8333-333333333308
# ╠═33333333-3333-4333-8333-333333333309
