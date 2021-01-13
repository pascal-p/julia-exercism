using Test

include("./larg_pal_prod.jl")

@testset "largest palindrome prod / 2 digit number" begin
  @test typeof(lpp(2)) <: Integer
  @test lpp(2) == 9009 # ≡ 99 × 91
end

@testset "largest palindrome prod / 3 digit number" begin
  @test lpp(3) == 906609  # 993 × 913
end

@testset "largest palindrome prod / 4 digit number" begin
  @test @time lpp(4) == 99000099  # 9999 × 9901
end

@testset "largest palindrome prod / 5 digit number" begin
  @test @time lpp(5) == 9966006699  # ≡ 99979 × 99681
end

@testset "largest palindrome prod / 6 digit number" begin
  @test @time lpp(6) == 999000000999
end

@testset "largest palindrome prod / 7 digit number" begin
  @test @time lpp(7) ≡ 99956644665999 # ≡ 9998017 × 9997647

  # julia> @time lpp(7)
  #   9.696088 seconds (333.90 M allocations: 14.927 GiB, 4.65% gc time)
  # 99956644665999
end

@testset "largest palindrome prod / 8 digit number" begin
  @test @time lpp₂(8)[1] ≡ 9999000000009999
end

@testset "largest palindrome prod / 9 digit number" begin
  @test @time lpp(9) ≡ 999900665566009999

  # 535.411342 seconds (13.47 G allocations: 702.690 GiB, 5.79% gc time)
  # Test Summary:                            | Pass  Total
  # largest palindrome prod / 9 digit number |    1      1
end

# @testset "largest palindrome prod / 9 digit number" begin
#   @test @time lpp(10) ≡ 9222630466640362229  # ≡ 9110958657 × 9110918549

#   # julia> @time lpp(10)
#   # 3115.660988 seconds (84.23 G allocations: 4.290 TiB, 4.19% gc time)
#   # 9222630466640362229

#   # julia> @time lpp(10)
#   # 2455.362135 seconds (71.26 G allocations: 3.629 TiB, 4.02% gc time)
#   # 9222225932395222229
# end

@testset "exceptions" begin
  @test_throws ArgumentError lpp(0)
  @test_throws ArgumentError lpp(-1)
  @test_throws ArgumentError lpp("aaa")
  @test_throws ArgumentError lpp(false)
end


# Test Summary:                            | Pass  Total
# largest palindrome prod / 2 digit number |    2      2

# Test Summary:                            | Pass  Total
# largest palindrome prod / 3 digit number |    1      1

#   0.000285 seconds (7.02 k allocations: 328.969 KiB)
# Test Summary:                            | Pass  Total
# largest palindrome prod / 4 digit number |    1      1

#   0.003572 seconds (90.74 k allocations: 4.154 MiB)
# Test Summary:                            | Pass  Total
# largest palindrome prod / 5 digit number |    1      1

#   0.026246 seconds (504.00 k allocations: 23.071 MiB, 26.59% gc time)
# Test Summary:                            | Pass  Total
# largest palindrome prod / 6 digit number |    1      1

#   0.871497 seconds (26.95 M allocations: 1.205 GiB, 5.43% gc time)
# Test Summary:                            | Pass  Total
# largest palindrome prod / 7 digit number |    1      1

#   2.163328 seconds (50.20 M allocations: 2.618 GiB, 6.19% gc time)
# Test Summary:                            | Pass  Total
# largest palindrome prod / 8 digit number |    1      1

# 284.500729 seconds (6.69 G allocations: 348.677 GiB, 6.44% gc time)
# Test Summary:                            | Pass  Total
# largest palindrome prod / 9 digit number |    1      1

# @time _lpp3(9)
# 202.269564 seconds (5.74 G allocations: 299.329 GiB, 4.17% gc time)
# (999900665566009999, 999980347, 999920317)
