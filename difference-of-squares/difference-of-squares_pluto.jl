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

# ╔═╡ 22222222-2222-4222-8222-222222222201
begin
    import Pkg
    Pkg.activate(dirname(@__DIR__))
    using Test
    using PlutoUI
end

# ╔═╡ 22222222-2222-4222-8222-222222222204
include("difference-of-squares.jl")

# ╔═╡ 22222222-2222-4222-8222-222222222202
md"""
# Difference Of Squares

Find the difference between the square of the sum and the sum of the squares of the first N natural numbers.

The square of the sum of the first ten natural numbers is
`(1 + 2 + ... + 10)² = 55² = 3025`.

The sum of the squares of the first ten natural numbers is
`1² + 2² + ... + 10² = 385`.

Hence the difference between the square of the sum of the first ten natural numbers and the sum of the squares of the first ten natural numbers is `3025 - 385 = 2640`.
"""

# ╔═╡ 22222222-2222-4222-8222-222222222203
md"""
## Solution (`difference-of-squares.jl`)
"""

# ╔═╡ 22222222-2222-4222-8222-222222222205
md"""
## Interactive Explorer
"""

# ╔═╡ 22222222-2222-4222-8222-222222222206
@bind n PlutoUI.Slider(0:200; default = 10, show_value = true)

# ╔═╡ 22222222-2222-4222-8222-222222222207
md"""
For `n = $(n)`:
- **Square of sum:** `$(format_n(square_of_sum(n)))`
- **Sum of squares:** `$(format_n(sum_of_squares(n)))`
- **Difference:** `$(format_n(difference(n)))`
"""

# ╔═╡ 22222222-2222-4222-8222-222222222208
md"""
## Test Suite
"""

# ╔═╡ 22222222-2222-4222-8222-222222222209
begin
    @testset "Square the sum of the numbers up to the given number" begin
        @test square_of_sum(5) == 225
        @test square_of_sum(10) == 3025
        @test square_of_sum(100) == 25502500
    end

    @testset "Sum the squares of the numbers up to the given number" begin
        @test sum_of_squares(5) == 55
        @test sum_of_squares(10) == 385
        @test sum_of_squares(100) == 338350
    end

    @testset "Subtract sum of squares from square of sums" begin
        @test difference(0) == 0
        @test difference(5) == 170
        @test difference(10) == 2640
        @test difference(100) == 25164150
    end
end

# ╔═╡ Cell order:
# ╠═22222222-2222-4222-8222-222222222201
# ╟─22222222-2222-4222-8222-222222222202
# ╟─22222222-2222-4222-8222-222222222203
# ╠═22222222-2222-4222-8222-222222222204
# ╟─22222222-2222-4222-8222-222222222205
# ╠═22222222-2222-4222-8222-222222222206
# ╠═22222222-2222-4222-8222-222222222207
# ╟─22222222-2222-4222-8222-222222222208
# ╠═22222222-2222-4222-8222-222222222209
