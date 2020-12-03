"""
  Convert files testfiles/mediumEWG.txt and testfiles/largeEWG.txt

Example of conversion

From:
10
4 3
3 8
6 5
9 4
2 1
8 9
5 0
7 2
6 1
1 0
6 7

To:
10
5 4
4 9
7 6
10 5
3 2
9 10
6 1
8 3
7 2
2 1
7 8
"""

function convert(infile::String, outfile::String, path::String)
  local fho
  every = 5000
  buffer = Vector{String}(undef, every)
  try
    fho = open(string(path, "/", outfile), "w")
    open(string(path, "/", infile), "r") do fhi

      ## read the first line only and write as is in output
      for line in eachline(fhi)
        write(fho, string(line, "\n"))
        break
      end

      # expecting 2 tokens: 2 int
      nline = 1
      for line in eachline(fhi)
        a = split(line, r"\s+")

        x, y = map(s -> parse(Int, s), a[1:2])
        buffer[nline] = "$(x + 1) $(y + 1)\n"
        nline += 1

        if nline > 5000
          write(fho, join(buffer, ""))
          nline = 1
        end
      end

      if nline > 0
        write(fho, join(buffer[1:nline - 1], ""))
        nline = 1
      end
    end
    println("Done - file $(infile) converted to $(outfile) - check in $(path)")

  catch err
    println("Intercepted error: $(err)")
    exit(1)

  finally
    close(fho)

  end
end

# REPL usage
#
# include("./utils/conv_file.jl")
#
# convert("tiny_uf.txt", "input_tiny_uf.txt", "./testfiles")
# convert("medium_uf.txt", "input_medium_uf.txt", "./testfiles")
# convert("large_uf.txt", "input_large_uf.txt", "./testfiles")
