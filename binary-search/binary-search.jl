"""
Binary Search (Assume array sorted, but can be in reverse order)
Assume duplicate values
"""
function binarysearch(
    ary::AbstractVector,
    elem;
    by = identity,
    lt = isless,
    rev::Bool = false,
    all::Bool = false,
)

    # empty array case
    isempty(ary) && return 1:0

    n = length(ary)  # 1-length array

    is_lt(x, y) = rev ? lt(by(y), by(x)) : lt(by(x), by(y))

    # general case
    l, r = 1, n
    found, m = false, -1

    while l ≤ r
        m = (l + r) ÷ 2

        if is_lt(elem, ary[m])
            r = m - 1

        elseif is_lt(ary[m], elem)
            l = m + 1

        else
            found = true  # value is m
            break
        end
    end

    if all       ## return all occurences
        if found
            lx = m
            m > l && (lx = find_others(ary, elem, lx, l))
            rx = m
            m < r && (rx = find_others(ary, elem, rx, r, cmp = isgreater, inc = 1))

            (lx:rx)
        else
            (l:(l-1)) # as l > r, i.e. l == r + 1, when elem is not found
        end
    else
        found ? (m:m) : (l:(l-1))
    end
end

function find_others(
    ary::AbstractVector,
    elem,
    ix::Integer,
    n::Integer;
    cmp = isless,
    inc::Integer = -1,
)
    while elem == ary[ix]
        ix += inc
        cmp(ix, n) && break
    end
    ix -= inc
end

isgreater(x::T, y::T) where {T} = x > y
