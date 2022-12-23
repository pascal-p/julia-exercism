using Test

include("grains.jl")

@testset "beginning squares" begin
  @test on_square(1) == 1
  @test on_square(2) == 2
  @test on_square(3) == 4
  @test on_square(4) == 8
  @test on_square(16) == 32768
  @test on_square(32) == 2147483648

  @test total_after(1) == 1
  @test total_after(3) == on_square(1) + on_square(2) + on_square(3)
end

@testset "ending squares" begin
  @test total_after(32) < total_after(64)

  N = 64
  @time @test on_square(N) == UInt(2)^(N - 1)     # ==  9_223_372_036_854_775_808
  @time @test total_after(N) == UInt128(2)^N - 1  # == 18_446_744_073_709_551_616
end

@testset "Invalid values" begin
  @testset "Zero" begin
    @test_throws DomainError on_square(0)
    @test_throws DomainError total_after(0)
  end

  @testset "Negative" begin
    @test_throws DomainError on_square(-1)
    @test_throws DomainError on_square(-100)
    @test_throws DomainError total_after(-1)
  end

  @testset "Greater than 64" begin
    @test_throws DomainError on_square(65)
    @test_throws DomainError total_after(65)
  end
end
