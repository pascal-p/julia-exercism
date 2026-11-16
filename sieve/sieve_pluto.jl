### A Pluto.jl notebook ###
# v1.1.0

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
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

# ╔═╡ 11111111-1111-4111-8111-111111111101
begin
    import Pkg
    Pkg.activate(dirname(@__DIR__))
    using Test
    using PlutoUI
end

# ╔═╡ 11111111-1111-4111-8111-111111111104
include("sieve.jl")

# ╔═╡ 11111111-1111-4111-8111-111111111102
md"""
# Sieve

Use the Sieve of Eratosthenes to find all the primes from 2 up to a given number.

The Sieve of Eratosthenes is a simple, ancient algorithm for finding all prime numbers up to any given limit. It does so by iteratively marking as composite (i.e. not prime) the multiples of each prime, starting with the multiples of 2. It does not use any division or remainder operation.

Create your range, starting at two and continuing up to and including the given limit (i.e. `[2, limit]`).

The algorithm consists of repeating the following over and over:

- take the next available unmarked number in your list (it is prime)
- mark all the multiples of that number (they are not prime)

Repeat until you have processed each number in your range.
When the algorithm terminates, all the numbers in the list that have not been marked are prime.
"""

# ╔═╡ 11111111-1111-4111-8111-111111111103
md"""
## Solution (`sieve.jl`)
"""

# ╔═╡ 11111111-1111-4111-8111-111111111105
md"""
## Interactive Explorer
"""

# ╔═╡ 11111111-1111-4111-8111-111111111106
@bind limit PlutoUI.Slider(1:200; default = 30, show_value = true)

# ╔═╡ 11111111-1111-4111-8111-111111111107
begin
    primes = sieve(limit)
    md"**Primes ≤ $(limit)** ($(length(primes)) found): `$(primes)`"
end

# ╔═╡ 11111111-1111-4111-8111-111111111108
md"""
## Test Suite
"""

# ╔═╡ 11111111-1111-4111-8111-111111111109
begin
    @testset "no primes under two" begin
        @test sieve(1) == []
    end

    @testset "find first prime" begin
        @test sieve(2) == [2]
    end

    @testset "find primes up to 10" begin
        @test sieve(10) == [2, 3, 5, 7]
    end

    @testset "limit is prime" begin
        @test sieve(13) == [2, 3, 5, 7, 11, 13]
    end
end

# ╔═╡ Cell order:
# ╠═11111111-1111-4111-8111-111111111101
# ╟─11111111-1111-4111-8111-111111111102
# ╟─11111111-1111-4111-8111-111111111103
# ╠═11111111-1111-4111-8111-111111111104
# ╟─11111111-1111-4111-8111-111111111105
# ╠═11111111-1111-4111-8111-111111111106
# ╠═11111111-1111-4111-8111-111111111107
# ╟─11111111-1111-4111-8111-111111111108
# ╠═11111111-1111-4111-8111-111111111109
