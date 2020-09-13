function to_roman(number)
  limit = 3000
  (number ≤ 0  || number > limit) &&
    throw(ErrorException("$(number) outside validity interval [0, $(limit)]"))

  ya_map = Dict{Int, String}(
    1 => "I", 2 => "II", 3 => "III", 4 => "IV", 5 => "V",
    6 => "VI", 7 => "VII", 8 => "VIII", 9 => "IX", 10 => "X",
    50 => "L", 100 => "C", 500 => "D", 1000 => "M"
  )
  haskey(ya_map, number) && return ya_map[number]
  roman, p = "", 1000

  ## Closure
  function roman_helper(num, p)
    targs = if num ≤ 3
      (ya_map[p] ^ num)                      # Ex. 30 => XXX

    elseif num == 4
      (ya_map[p], ya_map[5 * p])             # Ex. 40 => XL

    elseif num < 9
      (ya_map[5 * p], ya_map[p] ^ (num - 5)) # Ex. 70 => LXX

    else # 9
      @assert num == 9
      (ya_map[p], ya_map[10 * p])            # Ex. 90 => XC

    end

    string(roman, targs...)
  end

  while true
    num, rem = div(number, p), number % p

    if num > 0
      if p == 1000
        roman = string(roman, ya_map[p] ^ num)

      elseif p == 100 || p == 10
        roman = roman_helper(num, p)

      elseif p == 1
        roman = string(roman, ya_map[num])
      end
    end

    rem == 0 && break
    number, p = rem, div(p, 10)
  end

  return roman
end
