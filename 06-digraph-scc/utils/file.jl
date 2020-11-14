"""
  Convert from 1 format to the other, given the expected number of vertices

  origin:
  1 2
  1 3
  1 5
  1 4
  2 4
  2 3
  5 1
  5 2
  5 3

  after convertion:
  5
  1 2 3 5 4
  2 4 3
  3
  4
  5 1 2 3
"""
function convert(infile::String, outfile::String, nv::Int)
  fho = open(outfile, "w")
  nrl, nwl = 0, 0
  try
    write(fho, string(nv, "\n"))
    nwl += 1
    
    p_orig, lst = 0, []

    open(infile, "r") do fhi
      for line in eachline(fhi)
        nrl += 1
        (orig, dest) = split(line) # over space

        orig = parse(Int, orig)
        if orig == p_orig
          push!(lst, dest)
        else                       # orig != p_orig
          length(lst) > 0 && ((nwl, lst) = writeto(fho, p_orig, lst, nwl))
          while orig - p_orig > 1
            p_orig += 1
            write(fho, string(p_orig, "\n"))
            nwl += 1
          end

          p_orig = orig            # next origin vertex
          nv += 1
          push!(lst, dest)
        end
      end
    end

    # flush last line
    length(lst) > 0 && ((nwl, lst) = writeto(fho, p_orig, lst, nwl))
    
    println("$(infile) was converted to $(outfile) / $(nrl) lines read / $(nwl) lines written")

  catch err
    println("Intercepted error: $(err)")
    exit(1)

  finally
    close(fho)
  end
end

# convert("tests/problem8.10.txt", "tests/foo.txt", 875714)

function writeto(fho, p_orig, lst, nwl)
  write(fho, "$(p_orig) $(join(lst, ' '))\n")
  nwl += 1
  return (nwl, [])
end
