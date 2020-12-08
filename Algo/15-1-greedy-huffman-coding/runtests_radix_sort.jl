using Test

include("./src/radix_sort.jl")

const TF_DIR = "./testfiles"

function issorted(ary::Vector{Int}; lt=≤)
  flag = true
  for ix = 1:(length(ary) - 1)
    !lt(ary[ix], ary[ix+1]) && (flag = false; break)
  end
  flag
end

function slurp(infile::String)::Vector{Int}
  local ary
  open(infile, "r") do fh
    let n
      for line in eachline(fh)
        a = split(line, r"\s+")
        n = parse(Int, strip(a[1]))
        break
      end
      ary = zeros(Int, n)
    end

    for (ix, line) in enumerate(eachline(fh))
      a = split(line, r"\s+")
      ary[ix] = parse(Int, strip(a[1]))
    end
  end
  ary
end

@testset "#count_sort / 1" begin
  ary = [170, 45, 75, 90, 802, 24, 2, 66]

  counting_sort!(ary, 1)
  @test ary == [170, 90, 802, 2, 24, 45, 75, 66]

  counting_sort!(ary, 10)
  @test ary == [802, 2, 24, 45, 66, 170, 75, 90]

  counting_sort!(ary, 100)
  @test ary == [2, 24, 45, 66, 75, 90, 170, 802]
end

@testset "#count_sort / 2" begin
  ary = [121, 432, 564, 1, 23, 788,45]

  counting_sort!(ary, 1)
  @test ary == [121, 1, 432, 23, 564, 45, 788]

  counting_sort!(ary, 10)
  @test ary == [1, 121, 23, 432, 45, 564, 788]

  counting_sort!(ary, 100)
  @test ary == [1, 23, 45, 121, 432, 564, 788]
end


for file in filter((fs) -> occursin(r"\Ainput_random_\d+_\d+\.txt", fs),
                   cd(readdir, "$(TF_DIR)"))
  @testset "#radix_sort on $(file)" begin
    ary = slurp("$(TF_DIR)/$(file)")
    radix_sort!(ary)

    @test issorted(ary)
  end
end
