using Base: base36digits, base62digits

fₙ(n::Unsigned) = n == zero(Unsigned) ? zero(Unsigned) : fact_by(n + 1)

function fₙ(n::Integer)
  @assert n ≥ 0
  fₙ(unsigned(n))
end

fact_by(n::Unsigned, x = unsigned(2)) = (n * (n - 1)) ÷ x

function decompose(n::Unsigned)
  f = floor(Unsigned, (1 + √(1 + 8*n)) / 2) # highest factor base
  base = Unsigned[]
  cn = n
  while true
    x = fₙ(f)
    # println(" -- start with f: $(f) and x: $(x) >? cn: $(cn) // base: $(base)")
    while x > cn
      f -= 1
      x = fₙ(f)
    end
    # println("- Found factor $(f) value $(x) and cn - x ≥ 0 ? $(cn - x ≥ 0) && f ∉ base: $(f ∉ base)")
    if cn - x ≥ 0 && f ∉ base
      cn -= x
      push!(base, f)

      if cn == 0 && sum(fₙ.(base)) == n && length(base) == 3
        # println("- Success/1a - base is $(base)")
        return base |> vb -> Int.(vb) |> sort |> Tuple
      elseif cn == 0 && length(base) == 2
        if zero(Unsigned) ∉ base
          # println("- Success/1b - base is $([base..., 0])")
          return [base..., zero(Unsigned)] |> vb -> Int.(vb) |> sort |> Tuple
        end
        (cn, f, base) = redo(n, base)
        # println("- redo/1bb - with new factor $(f)")
        continue
      elseif cn ≥ 0 && length(base) < 3
        f = floor(Unsigned, (1 + √(1 + 8*cn)) / 2) # highest factor base
        # println("- Next/1c - with factor $(f)")
        continue
      else
        (cn, f, base) = redo(n, base)
        # println("- redo/1d - with new factor $(f)")
        continue
      end
      #
    else # cn - x < 0
      println("- // with factor: $(f) value $(x) and cn - x < 0...")
      f -= 1
      x = fₙ(f)

      while f > 0 && cn - x < 0
        f -= 1
        x = fₙ(f)
      end
      println("- // now we have factor: $(f) value $(x) - f ≥ 0? $(f ≥ 0) ")

      #if f ≥ 0
      cn -= x
      push!(base, f)

      if cn == 0 && sum(fₙ.(base)) == n && length(base) == 3
        println("- Success/2a - base is $(base)")
        return base |> vb -> Int.(vb) |> sort |> Tuple
      elseif cn == 0 && length(base) == 2
        if zero(Unsigned) ∉ base
          println("- Success/2b - base is $([base..., 0])")
          return [base..., zero(Unsigned)] |> vb -> Int.(vb) |> sort |> Tuple
        else
          (cn, f, base) = redo(n, base)
          println("- redo/2bb - with new factor $(f)")
          continue
        end
      elseif cn ≥ 0 && length(base) < 3
        f = floor(Unsigned, (1 + √(1 + 8*cn)) / 2) # highest factor base
        println("- Next/2c - with factor $(f)")
        continue
      else
        (cn, f, base) = redo(n, base)
        println("- redo/2d - with new factor $(f)")
        continue
      end
    end
  end
end

function decompose(n::Integer)
  @assert n ≥ 0
  decompose(unsigned(n))
end

function redo(n, base)
  f = base[1] - 1
  base = Unsigned[]
  (n, f, base)
end
