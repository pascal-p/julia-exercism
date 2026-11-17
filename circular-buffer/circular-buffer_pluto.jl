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

# ╔═╡ 33333333-3333-4333-8333-333333333301
begin
    import Pkg
    Pkg.activate(dirname(@__DIR__))
    using Test
    using PlutoUI
end

# ╔═╡ 33333333-3333-4333-8333-333333333304
include("circular-buffer.jl")

# ╔═╡ 33333333-3333-4333-8333-333333333302
md"""
# Circular Buffer

A circular buffer, cyclic buffer, or ring buffer is a data structure that uses a single, fixed-size buffer as if it were connected end-to-end.
"""

# ╔═╡ 33333333-3333-4333-8333-333333333303
md"""
## Solution (`circular-buffer.jl`)
"""

# ╔═╡ 33333333-3333-4333-8333-333333333305
md"""
## Interactive Ring Buffer Explorer
"""

# ╔═╡ 33333333-3333-4333-8333-333333333306
begin
    md"""
    - Capacity: $(@bind cap PlutoUI.Slider(2:12; default = 5, show_value = true))
    - Items to push (`1:n`): $(@bind n_items PlutoUI.Slider(0:16; default = 7, show_value = true))
    - Overwrite when full: $(@bind overwrite PlutoUI.CheckBox(default = true))
    """
end

# ╔═╡ 33333333-3333-4333-8333-333333333307
begin
    cb_demo = CircularBuffer{Int}(cap)
    append!(cb_demo, 1:n_items; overwrite)
    md"""
    - **Logical contents (`collect(cb)`):** `$(collect(cb_demo))`
    - **Raw backing buffer:** `$(cb_demo.buffer)`
    - **State:** `length = $(Int(length(cb_demo))) / $(Int(capacity(cb_demo)))`, `head = $(Int(cb_demo.head))`, `tail = $(Int(cb_demo.tail))`, `isfull = $(isfull(cb_demo))`
    """
end

# ╔═╡ 33333333-3333-4333-8333-333333333308
md"""
## Core Tests
"""

# ╔═╡ 33333333-3333-4333-8333-333333333309
begin
    @testset "basic circular buffer checks" begin
        cb = CircularBuffer{Int}(3)
        @test isempty(cb)
        append!(cb, [10, 20, 30])
        @test isfull(cb)
        @test popfirst!(cb) == 10
        push!(cb, 40)
        @test collect(cb) == [20, 30, 40]
        push!(cb, 50; overwrite = true)
        @test collect(cb) == [30, 40, 50]
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
