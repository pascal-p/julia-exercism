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



"""
  Example: convert_ewg("mediumEWD.txt", "medium_ewd.txt")
  Assume file was pre-sorted, to group vertices together ( then shuffled but grouping maintained)

  From:
250
2546
244 246 0.11712
246 244 0.11712
239 240 0.10616
239 230 0.11656
...

  To:
250
245 247,0.11712
247 245 0.11712
240 241,0.10616 231,0.11656
...
"""
function convert_ewg(infile::String, outfile::String)
  nrl, nwl = 0, 0  # read lines / written lines
  local fho

  #try
    fho = open(outfile, "w")

    p_orig, lst, nv = 0, [], 0
    open(infile, "r") do fhi
      for line in eachline(fhi)
        nv = parse(Int, strip(split(line)[1]))
        nrl += 1
        break
      end

      write(fho, string(nv, "\n"))  ## copy num. of vertices
      nwl += 1

      for line in eachline(fhi)
        nrl += 1
        (s_orig, s_dest, s_weight) = split(strip(line))

        orig = parse(Int, s_orig) + 1  ## bump every vertex by 1
        dest = parse(Int, s_dest) + 1

        if orig == p_orig # same origin
          push!(lst, (string(dest), s_weight))

        else
          if length(lst) > 0    ## change of origin, write to dest file and reset
            nwl = writeto_ewg(fho, p_orig, lst, nwl)
            lst = []
          end

          # first item in lst
          push!(lst, (string(dest), s_weight))
          p_orig = orig
        end
      end  ## for
    end    ## open

    length(lst) > 0 && (nwl = writeto_ewg(fho, p_orig, lst, nwl))
    println("$(infile) was converted to $(outfile) / $(nrl) lines read / $(nwl) lines written")

  #catch err
  #  println("Intercepted error: $(err)")
  #  exit(1)

  #finally
  #  close(fho)
  #end
end


## convert("tests/problem8.10.txt", "tests/foo.txt", 875714)

function writeto(fho, p_orig, lst, nwl)
  write(fho, "$(p_orig) $(join(lst, ' '))\n")
  nwl += 1
  return (nwl, [])
end

function writeto_ewg(fho, p_orig, lst, nwl)
  ary = map(t -> string(t[1], ",", t[2]), lst)
  write(fho, "$(p_orig) $(join(ary, ' '))\n")
  nwl += 1
end
