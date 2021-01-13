using Test

include("./larg_pal_prod.jl")

@testset "largest palindrome prod / 2 digit number" begin
  @test typeof(lpp₂(2)[1]) <: Integer
  @test lpp₂(2)[1] == 9009 # ≡ 99 × 91
end

@testset "largest palindrome prod / 3 digit number" begin
  @test lpp₂(3)[1] == 906609  # 993 × 913
end

@testset "largest palindrome prod / 4 digit number" begin
  @test @time lpp₂(4)[1] == 99000099  # 9999 × 9901
end

@testset "largest palindrome prod / 5 digit number" begin
  @test @time lpp₂(5)[1] == 9966006699
end

@testset "largest palindrome prod / 6 digit number" begin
  @test @time lpp₂(6)[1] == 999000000999
end

@testset "largest palindrome prod / 7 digit number" begin
  @test @time lpp₂(7)[1] ≡ 99956644665999
end

@testset "largest palindrome prod / 8 digit number" begin
  @test @time lpp₂(8)[1] ≡ 9999000000009999
end

@testset "largest palindrome prod / 9 digit number" begin
  @test @time lpp₂(9; f=0.00099)[1] ≡ 999900665566009999

  # with default f=0.09
  # 509.019891 seconds (12.85 G allocations: 670.355 GiB, 5.90% gc time)
  # Test Summary:                            | Pass  Total
  # largest palindrome prod / 9 digit number |    1      1

  # with f=0.0009
  # 249.240231 seconds (6.67 G allocations: 348.022 GiB, 5.74% gc time)
  # Test Summary:                            | Pass  Total
  # largest palindrome prod / 9 digit number |    1      1
end

# @testset "largest palindrome prod / 9 digit number" begin
#   @test @time lpp(10) ≡ 9222630466640362229  # ≡ 9110958657 × 9110918549

#   # with f=0.09
#   # julia> @time _lpp3(10; f = 0.09)
#   # 2323.484184 seconds (65.58 G allocations: 3.340 TiB, 4.58% gc time)
#   # (9222225932395222229, 9110958657, 9110918549)
# end

@testset "exceptions" begin
  @test_throws ArgumentError lpp(0)
  @test_throws ArgumentError lpp(-1)
  @test_throws ArgumentError lpp("aaa")
  @test_throws ArgumentError lpp(false)
end
