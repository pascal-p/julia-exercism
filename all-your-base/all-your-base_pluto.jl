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

# ╔═╡ 44444444-4444-4444-8444-444444444401
begin
    import Pkg
    Pkg.activate(dirname(@__DIR__))
    using Test
    using PlutoUI
end

# ╔═╡ 44444444-4444-4444-8444-444444444402
md"""
# All Your Base

Convert a number, represented as a sequence of digits in `base_in`, to `base_out`.
This notebook lets you explore both the `Imperative()` and `Functional()` strategies in `all-your-base.jl`.
"""

# ╔═╡ 44444444-4444-4444-8444-444444444403
md"""
## Solution (`all-your-base.jl`)
"""

# ╔═╡ 44444444-4444-4444-8444-444444444404
include("all-your-base.jl")

# ╔═╡ 44444444-4444-4444-8444-444444444405
md"""
## Interactive Explorer
"""

# ╔═╡ 44444444-4444-4444-8444-444444444406
@bind n PlutoUI.Slider(0:1000; default = 42, show_value = true)

# ╔═╡ 44444444-4444-4444-8444-444444444407
@bind base_out PlutoUI.Slider(2:36; default = 2, show_value = true)

# ╔═╡ 44444444-4444-4444-8444-444444444408
begin
    in_digits = reverse!(Base.digits(n; base = 10))
    imp = all_your_base(in_digits, 10, base_out; style = Imperative())
    fun = all_your_base(in_digits, 10, base_out; style = Functional())
    md"""
    - **Decimal `$(n)`** (`$(in_digits)` in base `10`) → **base `$(base_out)`**:
      - `Imperative()`: `$(imp)`
      - `Functional()`: `$(fun)`
      - **Match:** `$(imp == fun)`
    """
end

# ╔═╡ 44444444-4444-4444-8444-444444444409
md"""
## Test Suite
"""

# ╔═╡ 44444444-4444-4444-8444-444444444410
begin
    for style in (Imperative(), Functional())
        @testset "core conversions ($style)" begin
            @test all_your_base([1, 0, 1, 0, 1, 0], 2, 10; style) == [4, 2]
            @test all_your_base([4, 2], 10, 2; style) == [1, 0, 1, 0, 1, 0]
            @test all_your_base([1, 1, 2, 0], 3, 16; style) == [2, 10]
            @test all_your_base([0, 6, 0], 10, 10; style) == [6, 0]
            @test all_your_base([], 2, 10; style) == [0]
        end
    end
end

# ╔═╡ Cell order:
# ╠═44444444-4444-4444-8444-444444444401
# ╟─44444444-4444-4444-8444-444444444402
# ╟─44444444-4444-4444-8444-444444444403
# ╠═44444444-4444-4444-8444-444444444404
# ╟─44444444-4444-4444-8444-444444444405
# ╠═44444444-4444-4444-8444-444444444406
# ╠═44444444-4444-4444-8444-444444444407
# ╠═44444444-4444-4444-8444-444444444408
# ╟─44444444-4444-4444-8444-444444444409
# ╠═44444444-4444-4444-8444-444444444410
