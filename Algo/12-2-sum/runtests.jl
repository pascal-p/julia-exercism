using Test

include("./2-sum.jl")

for ifile in ["input_random_37_5120.txt",
             "input_random_38_5120.txt",
             "input_random_12_40.txt",
             "input_random_23_320.txt",
             "input_random_59_160000.txt",
             "input_random_66_640000.txt",
             "input_random_39_5120.txt",
             "input_random_11_40.txt",
             "input_random_48_20000.txt",
             "input_random_16_80.txt",
             "input_random_36_2560.txt",
             "input_random_58_160000.txt",
             "input_random_49_40000.txt",
             "input_random_67_640000.txt" ]

  @testset "$(ifile)" begin
    ofile = replace(ifile, r"\Ainput" => "output")

    # slurp content
    klines = open("./testfiles/$(ofile)", "r") do fh
      readlines(fh)
    end

    # range
    from, to = split(split(klines[1], " ")[1], ":")[2:end] |> a -> map(s -> parse(Int, s), a)

    # expected distinct sums:
    exp_nsum = split(klines[1], " ")[end] |> s -> parse(Int, s) 

    act_nsum, _ = two_sum("./testfiles/$(ifile)"; targets=from:to, distinct=true, keep=false)
    
    @test exp_nsum == act_nsum    
  end
  
end


# @testset "input_random_37_5120.txt" begin
  
# end

# @testset "input_random_38_5120.txt" begin
# end

# @testset "input_random_12_40.txt" begin
# end

# @testset "input_random_23_320.txt" begin
# end

# @testset "input_random_59_160000.txt" begin
# end

# @testset "input_random_66_640000.txt" begin
# end

# @testset "input_random_39_5120.txt" begin
# end

# @testset "input_random_11_40.txt" begin
# end

# @testset "input_random_48_20000.txt" begin
# end

# @testset "input_random_16_80.txt" begin
# end

# @testset "input_random_36_2560.txt" begin
# end

# @testset "input_random_58_160000.txt" begin
# end

# @testset "input_random_49_40000.txt" begin
# end

# @testset "input_random_67_640000.txt" begin
# end


