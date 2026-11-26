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
# Rotational Cipher

Create an implementation of the rotational (Caesar) cipher, shifting ASCII Latin letters by an integer key `n` modulo `26` while preserving case, digits, whitespace, punctuation, and non-ASCII characters.

Also provides compile-time non-standard string literals `R0"..."` through `R26"..."`.
"""

# ╔═╡ 44444444-4444-4444-8444-444444444403
md"""
## Solution (`rotational-cipher.jl`)
"""

# ╔═╡ 44444444-4444-4444-8444-444444444404
include("rotational-cipher.jl")

# ╔═╡ 44444444-4444-4444-8444-444444444405
md"""
## Interactive Explorer
"""

# ╔═╡ 44444444-4444-4444-8444-444444444406
@bind shift PlutoUI.Slider(-26:26; default = 13, show_value = true)

# ╔═╡ 44444444-4444-4444-8444-444444444407
@bind plaintext PlutoUI.TextField(
    (48, 1);
    default = "The quick brown fox jumps over the lazy dog.",
)

# ╔═╡ 44444444-4444-4444-8444-444444444408
begin
    ciphertext = rotate(shift, plaintext)
    roundtrip = rotate(-shift, ciphertext)
    md"""
    - **Shift:** `$(shift)` (effective `mod($(shift), 26) = $(mod(shift, 26))`)
    - **Plaintext:** `$(plaintext)`
    - **Ciphertext:** `$(ciphertext)`
    - **Decoded (`rotate($(-shift), ciphertext)`):** `$(roundtrip)`
    """
end

# ╔═╡ 44444444-4444-4444-8444-444444444409
md"""
## Test Suite
"""

# ╔═╡ 44444444-4444-4444-8444-444444444410
begin
    @testset "rotate function" begin
        @test rotate(1, 'a') == 'b'
        @test rotate(13, 'n') == 'a'
        @test rotate(-1, 'a') == 'z'
        @test rotate(5, "OMG") == "TRL"
        @test rotate(13, "The quick brown fox jumps over the lazy dog.") ==
              "Gur dhvpx oebja sbk whzcf bire gur ynml qbt."
        @test rotate(13, "hello-world (2026)!") == "uryyb-jbeyq (2026)!"
        @test rotate(1, "café") == "dbgé"
        @test rotate(Int32(13), 'm') == 'z'
        @test rotate(13, SubString("hello world", 1, 5)) == "uryyb"
    end

    @testset "string literals" begin
        @test R5"OMG" == "TRL"
        @test R13"The quick brown fox jumps over the lazy dog." ==
              "Gur dhvpx oebja sbk whzcf bire gur ynml qbt."
        @test R0"Hello, World!" == R26"Hello, World!"
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
