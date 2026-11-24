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
        found &&
            (return lower_bound(ary, elem, l, m, is_lt):upper_bound(ary, elem, m, r, is_lt))

        return (l:(l-1)) # as l > r, i.e. l == r + 1, when elem is not found
    end
    found ? (m:m) : (l:(l-1))
end

function lower_bound(ary::AbstractVector, elem, lo::Int, hi::Int, is_lt)
    while lo < hi
        mid = lo + (hi - lo) ÷ 2
        if is_lt(ary[mid], elem)
            lo = mid + 1
        else
            hi = mid
        end
    end
    lo
end

function upper_bound(ary::AbstractVector, elem, lo::Int, hi::Int, is_lt)
    while lo < hi
        mid = lo + (hi - lo + 1) ÷ 2   # ceiling midpoint so lo = mid always progresses 
        if is_lt(elem, ary[mid])
            hi = mid - 1
        else
            lo = mid
        end
    end
    lo
end
