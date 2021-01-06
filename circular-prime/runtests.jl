using Test

include("./circular_prime.jl")


@testset "correctness" begin

  @test typeof(circular_prime(100)) <: Integer

  @time res = circular_prime(100)
  @test res == 13
end

@testset "circular_prime(200)" begin
  @time res = circular_prime(200)
  @test res == 15 # or 14
end

@testset "circular_prime(500)" begin
  @time res = circular_prime(500)
  @test res == 20 # or 17?
end

@testset "circular_prime(1000)" begin
  @time res = circular_prime(1000)
  @test res == 25
end

@testset "circular_prime(2000)" begin
  @time res= circular_prime(2000)
  @test res == 25 # or 29
end

@testset "circular_prime(100_000)" begin
  @time res = circular_prime(100_000)
  @test res == 43
  # OK so far
end

@testset "circular_prime(250_000)" begin
  @time res = circular_prime(250_000)
  @test res == 45  # 43!
end

@testset "circular_prime(500_000)" begin
  @time res = circular_prime(500000)
  @test res == 49   # 43!
end

@testset "circular_prime(750_000)" begin
  @time res = circular_prime(750000)
  @test res == 49     # 43!
end

@testset "circular_prime(1_000_000)" begin
  @time res = circular_prime(1_000_000)
  @test res == 55    # OK
end


#   0.000033 seconds (336 allocations: 26.672 KiB)
# Test Summary: | Pass  Total
# correctness   |    2      2

#   0.000050 seconds (839 allocations: 52.578 KiB)
# Test Summary:       | Pass  Total
# circular_prime(200) |    1      1

#   0.000110 seconds (2.28 k allocations: 127.375 KiB)
# Test Summary:       | Pass  Total
# circular_prime(500) |    1      1

#   0.000230 seconds (4.76 k allocations: 241.875 KiB)
# Test Summary:        | Pass  Total
# circular_prime(1000) |    1      1

#   0.006970 seconds (24.13 k allocations: 1.141 MiB)
# Test Summary:        | Pass  Total
# circular_prime(2000) |    1      1

#   0.509627 seconds (505.15 k allocations: 19.967 MiB, 0.61% gc time)
# Test Summary:           | Pass  Total
# circular_prime(100_000) |    1      1

#   3.659952 seconds (1.26 M allocations: 48.455 MiB, 0.06% gc time)
# Test Summary:           | Pass  Total
# circular_prime(250_000) |    1      1

#  14.983249 seconds (2.49 M allocations: 94.518 MiB, 0.10% gc time)
# Test Summary:           | Pass  Total
# circular_prime(500_000) |    1      1

#  32.298199 seconds (3.68 M allocations: 139.505 MiB, 0.17% gc time)
# Test Summary:           | Pass  Total
# circular_prime(750_000) |    1      1

# 56.153183 seconds (4.86 M allocations: 183.900 MiB, 0.13% gc time)
# Test Summary:             | Pass  Total
# circular_prime(1_000_000) |    1      1
