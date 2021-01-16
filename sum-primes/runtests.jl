using Test

include("./sum_primes.jl")


@testset "basics" begin

  @test typeof(sum_primes(17)) <: Integer

  @test sum_primes(17) == 58 # sum([2, 3, 5, 7, 11, 13, 17])

  @test sum_primes(2001) == 277_050

  @test sum_primes(140_759) == 873_749_121

  @test sum_primes(2_000_000) == 142_913_828_922

end
