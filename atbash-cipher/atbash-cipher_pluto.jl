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
# Atbash Cipher

Create an implementation of the Atbash cipher, mirroring the ASCII Latin alphabet (`a` ↔ `z`, `b` ↔ `y`, …) while preserving digits `0`–`9`, normalizing to lowercase, dropping punctuation/spaces/non-ASCII characters, and grouping encoded output into 5-character blocks.
"""

# ╔═╡ 55555555-5555-4555-8555-555555555503
md"""
## Solution (`atbash-cipher.jl`)
"""

# ╔═╡ 55555555-5555-4555-8555-555555555504
include("atbash-cipher.jl")

# ╔═╡ 55555555-5555-4555-8555-555555555505
md"""
## Interactive Explorer
"""

# ╔═╡ 55555555-5555-4555-8555-555555555506
@bind plaintext PlutoUI.TextField(
    (48, 1);
    default = "The quick brown fox jumps over the lazy dog.",
)

# ╔═╡ 55555555-5555-4555-8555-555555555507
begin
    encoded = encode(plaintext)
    decoded = decode(encoded)
    md"""
    - **Plaintext:** `$(plaintext)`
    - **Encoded (`encode`):** `$(encoded)`
    - **Decoded (`decode`):** `$(decoded)`
    """
end

# ╔═╡ 55555555-5555-4555-8555-555555555508
md"""
## Test Suite
"""

# ╔═╡ 55555555-5555-4555-8555-555555555509
begin
    @testset "encoding from English to atbash" begin
        @test encode("yes") == "bvh"
        @test encode("OMG") == "lnt"
        @test encode("mindblowingly") == "nrmwy oldrm tob"
        @test encode("Testing,1 2 3, testing.") == "gvhgr mt123 gvhgr mt"
        @test encode("The quick brown fox jumps over the lazy dog.") ==
              "gsvjf rxpyi ldmul cqfnk hlevi gsvoz abwlt"
        @test encode("yes") isa String
    end

    @testset "decoding from atbash to English" begin
        @test decode("vcvix rhn") == "exercism"
        @test decode("gvhgr mt123 gvhgr mt") == "testing123testing"
        @test decode("gsvjf rxpyi ldmul cqfnk hlevi gsvoz abwlt") ==
              "thequickbrownfoxjumpsoverthelazydog"
        @test decode("bvh") isa String
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
# ╟─55555555-5555-4555-8555-555555555508
# ╠═55555555-5555-4555-8555-555555555509
