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
# Prime Factors

Compute the prime factorization of a positive integer `n::T` (`T <: Integer`), returning a type-preserving `Vector{T}` in non-decreasing order.

Supports both trial division (`pf_trial`) and mod-30 wheel factorization (`pf_wheel`, default).
"""

# ╔═╡ 66666666-6666-4666-8666-666666666603
md"""
## Solution (`prime-factors.jl`)
"""

# ╔═╡ 66666666-6666-4666-8666-666666666604
include("prime-factors.jl")

# ╔═╡ 66666666-6666-4666-8666-666666666605
md"""
## Interactive Explorer
"""

# ╔═╡ 66666666-6666-4666-8666-666666666606
@bind n_input PlutoUI.NumberField(1:10_000_000_000; default = 901255)

# ╔═╡ 66666666-6666-4666-8666-666666666607
@bind algo_choice PlutoUI.Select([
    pf_wheel => "pf_wheel (mod-30 wheel)",
    pf_trial => "pf_trial (trial division)",
])

# ╔═╡ 66666666-6666-4666-8666-666666666608
begin
    factors = prime_factors(n_input; algo = algo_choice)
    md"""
    - **Input (`$(typeof(n_input))`):** `$(n_input)`
    - **Algorithm:** `$(algo_choice)`
    - **Prime factors (`$(typeof(factors))`):** `$(factors)`
    - **Product check:** `$(isempty(factors) ? 1 : prod(factors)) == $(n_input)`
    """
end

# ╔═╡ 66666666-6666-4666-8666-666666666609
md"""
## Test Suite
"""

# ╔═╡ 66666666-6666-4666-8666-666666666610
begin
    for algo in (pf_trial, pf_wheel)
        @testset "prime_factors ($(algo))" begin
            @test prime_factors(1; algo) == Int[]
            @test prime_factors(1; algo) isa Vector{Int}
            @test prime_factors(2; algo) == [2]
            @test prime_factors(9; algo) == [3, 3]
            @test prime_factors(60; algo) == [2, 2, 3, 5]
            @test prime_factors(901255; algo) == [5, 17, 23, 461]
            @test prime_factors(93819012551; algo) == [11, 9539, 894119]
            @test prime_factors(Int32(60); algo) isa Vector{Int32}
            @test prime_factors(BigInt(2)^130; algo) == fill(BigInt(2), 130)
            @test_throws DomainError prime_factors(0; algo)
            @test_throws DomainError prime_factors(-5; algo)
        end
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
