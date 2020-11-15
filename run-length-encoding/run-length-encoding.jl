function check_valid(ch)
  ch = lowercase(ch)
  (ch < 'a' || ch > 'z') && ch != ' ' && throw(ArgumentError("Not a valid character"))
end

function encode(str::String)::String
  length(str) == 0 && (return "")

  count = 1
  pch, nstr = str[1], ""
  check_valid(pch)

  for cch in str[2:end]
    check_valid(cch)

    if cch == pch
      count += 1

    else
      nstr = string(nstr, count > 1 ? count : "", pch)
      count, pch = 1, cch
    end
  end

  # add last char, and implicitly return it
  nstr = string(nstr, count > 1 ? count : "", pch)
end

function decode(str::String)::String
  length(str) == 0 && (return "")
  check_valid(str[end])

  snum, num, dec = "", 0, ""
  for cch in str
    if '0' ≤ cch ≤ '9'
      snum = string(snum, cch)  # keep going

    elseif 'a' ≤ lowercase(cch) ≤ 'z' || cch == ' '
      if length(snum) > 0
        num = parse(typeof(num), snum)
        dec = string(dec, cch ^ num)
        snum, num = "", 0  # reset
      else
        dec = string(dec, cch)
      end

    else
      throw(ArgumentError("Not a valid character"))
    end
  end

  dec
end
