using Test

include("./nth_prime.jl")

function prime_range(n)
  """Returns a list of the first primes less than n"""
  [YaPrime.nth_prime(i) for i ∈ 1:n]
end


@testset "basic" begin
  @test YaPrime.nth_prime(1) ≡ 2

  @test YaPrime.nth_prime(2) ≡ 3

  @test YaPrime.nth_prime(3) ≡ 5

  @test YaPrime.nth_prime(4) ≡ 7

  @test YaPrime.nth_prime(6) ≡ 13

  @test YaPrime.nth_prime(16) ≡ 53

  @test YaPrime.nth_prime(100) ≡ 541

  @test YaPrime.nth_prime(400) ≡ 2741

  @test YaPrime.nth_prime(700) ≡ 5279

  @test YaPrime.nth_prime(1049) ≡ 8377

  @test YaPrime.nth_prime(10001) ≡ 104743

  @test YaPrime.nth_prime(20_001) ≡ 224_743

  @test @time prime_range(168) == [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97, 101, 103, 107, 109, 113, 127, 131, 137, 139, 149, 151, 157, 163, 167, 173, 179, 181, 191, 193, 197, 199, 211, 223, 227, 229, 233, 239, 241, 251, 257, 263, 269, 271, 277, 281, 283, 293, 307, 311, 313, 317, 331, 337, 347, 349, 353, 359, 367, 373, 379, 383, 389, 397, 401, 409, 419, 421, 431, 433, 439, 443, 449, 457, 461, 463, 467, 479, 487, 491, 499, 503, 509, 521, 523, 541, 547, 557, 563, 569, 571, 577, 587, 593, 599, 601, 607, 613, 617, 619, 631, 641, 643, 647, 653, 659, 661, 673, 677, 683, 691, 701, 709, 719, 727, 733, 739, 743, 751, 757, 761, 769, 773, 787, 797, 809, 811, 821, 823, 827, 829, 839, 853, 857, 859, 863, 877, 881, 883, 887, 907, 911, 919, 929, 937, 941, 947, 953, 967, 971, 977, 983, 991, 997]
end

@testset "bigger value" begin
  @test @time YaPrime.nth_prime(50_001) ≡ 611_957

  @test @time YaPrime.nth_prime(100_001) ≡ 1_299_721

  @test @time YaPrime.nth_prime(500_001) ≡ 7_368_791

  @test @time YaPrime.nth_prime(1_000_001) ≡ 15_485_867

  @test @time YaPrime.nth_prime(10_000_001) ≡ 179_424_691

  @test @time YaPrime.nth_prime(10_000_003) ≡ 179_424_719 # should be fast (because already computed)
end
