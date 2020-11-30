"""
  Convert files testfiles/mediumEWG.txt and testfiles/largeEWG.txt

Example of conversion

From:
250 1273
244 246 0.11712
239 240 0.10616
238 245 0.06142
...
0 211 0.08438
0 222 0.07573
0 225 0.02383

To:
250 1273
245 247 11712
239 240 10616
238 245 6142
...
1 212 8438
1 223 7573
1 226 2383

"""

const mapping = Dict{String, Int}("large_ewg.txt" => 100_000_000, "medium_ewg.txt" => 100_000)

function convert(infile::String, outfile::String, path::String)
  fact = if infile == "large_ewg.txt" || infile == "medium_ewg.txt"
    mapping[infile]
  else
    throw(ArgumentError("$(infile) not managed!"))
  end

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

      # expecting 3 tokens 2 int 1 float space separated
      nline = 1
      for line in eachline(fhi)
        a = split(line, r"\s+")

        x, y = map(s -> parse(Int, s), a[1:2])
        c = floor(Int, parse(Float64, a[end]) * fact)  # no overflow expected
        buffer[nline] = "$(x + 1) $(y + 1) $(c)\n" # buffer = string(buffer, "$(x + 1) $(y + 1) $(c)\n")
        nline += 1

        if nline > 5000
          write(fho, join(buffer, ""))
          nline = 1
        end
      end

      if nline > 0
        write(fho, join(buffer[1:nline-1], ""))
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
# include("./utils/conv_file.jl")
# convert("medium_ewg.txt", "medium_ewg-challenge.txt", "./testfiles")
# convert("large_ewg.txt", "large_ewg-challenge.txt", "./testfiles")
