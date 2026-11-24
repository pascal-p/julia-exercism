"""
Custom set implementation

"""

# const ∩ = intersect

import Base: ==, ≠, ∈, ∉, intersect, intersect!
import Base: iterate, isempty, length, keys, issubset, push!, copy, union, union!, show


struct CustomSet{T} <: AbstractSet{T}
    hsh::Dict{T,Nothing}

    # build empty set
    CustomSet{T}() where {T} = new(Dict{T,Nothing}())

    # build set given a set
    CustomSet{T}(s::CustomSet{T}) where {T} = new(Dict{T,Nothing}(s.hsh))
end

function CustomSet(ary::Vector{T}) where {T}
    isempty(ary) && return CustomSet{T}()

    s = CustomSet{T}()
    for elt in ary
        s.hsh[elt] = nothing
    end

    return s
end

iterate(s::CustomSet{T}, ix...) where {T} = iterate(keys(s.hsh), ix...)

isempty(s::CustomSet{T}) where {T} = iszero(length(s.hsh))

length(s::CustomSet{T}) where {T} = length(s.hsh)

∈(elt, s::CustomSet) = haskey(s.hsh, elt)

keys(s::CustomSet{T}) where {T} = keys(s.hsh)

==(s₁::CustomSet, s₂::CustomSet) = length(s₁) == length(s₂) && issubset(s₁, s₂)

issubset(s₁::CustomSet, s₂::CustomSet) = length(s₁) ≤ length(s₂) && all(∈(s₂), s₁)

function disjoint(s₁::CustomSet, s₂::CustomSet)
    (isempty(s₁) || isempty(s₂)) && return true

    small, big = length(s₁) ≤ length(s₂) ? (s₁, s₂) : (s₂, s₁)
    all(∉(big), small)
end

function push!(s::CustomSet, elt)
    s.hsh[elt] = nothing
    return s
end

add(s::CustomSet, elt) = push!(s, elt)

copy(s::CustomSet{T}) where {T} = CustomSet{T}(s)

function intersect(s₁::CustomSet{T1}, s₂::CustomSet{T2}) where {T1,T2}
    s = CustomSet{promote_type(T1, T2)}()
    (isempty(s₁) || isempty(s₂)) && return s

    small, big = length(s₁) ≤ length(s₂) ? (s₁, s₂) : (s₂, s₁)
    for elt ∈ small
        elt ∈ big && push!(s, elt)
    end
    return s
end

function intersect!(s₁::CustomSet, s₂::CustomSet)
    isempty(s₁) && return s₁
    if isempty(s₂)
        empty!(s₁.hsh)
        return s₁
    end

    for elt ∈ s₁
        elt ∉ s₂ && delete!(s₁.hsh, elt)
    end
    return s₁
end

function complement(s₁::CustomSet{T1}, s₂::CustomSet) where {T1}
    (isempty(s₁) || isempty(s₂)) && return copy(s₁)

    s = CustomSet{T1}()
    for elt ∈ s₁
        elt ∉ s₂ && push!(s, elt)
    end
    return s
end

function complement!(s₁::CustomSet, s₂::CustomSet)
    (isempty(s₁) || isempty(s₂)) && return s₁

    for elt ∈ s₁
        elt ∈ s₂ && delete!(s₁.hsh, elt)
    end
    return s₁
end

function union(s₁::CustomSet{T1}, s₂::CustomSet{T2}) where {T1,T2}
    s = CustomSet{promote_type(T1, T2)}()
    union!(s, s₁)
    union!(s, s₂)
    return s
end

function union!(s₁::CustomSet, s₂::CustomSet)
    for elt ∈ s₂
        push!(s₁, elt)
    end
    return s₁
end

function show(io::IO, s::CustomSet)
    if isempty(s)
        if get(io, :typeinfo, Any) == typeof(s)
            print(io, "CustomSet()")
        else
            show(io, typeof(s))
            print(io, "()")
        end
    else
        print(io, "CustomSet(")
        Base.show_vector(io, collect(s))
        print(io, ')')
    end
end
