using Test

include("diffie_hellman.jl");

@testset "calculate pubkey given privkey" begin
  for (p, g, privkey, exp) ∈ [ (23, 5, 6, 8),
                               (2951, 8713, 2931, 2757),
                               (29501, 8713, 29331, 15518) ]
    @test exp == public_key(p, g, privkey)
  end
end

@testset "calculate secret using other party pubkey" begin
  for (p, their_pubkey, our_privkey, exp) ∈ [(23, 19, 6, 2),
                                             (3967, 3017, 3849, 1015),
                                             (29501, 8017, 8849, 184)]
    @test exp == calc_secret(p, their_pubkey, our_privkey)
  end
end

@testset "test private key in range" begin
  primes = [100000937, 100000939,100000963, 100000969, 100001029, 100001053, 100001059, 100001081, 100001087, 100001107,
            100001119, 100001131, 100001147, 100001159, 100001177, 100001183, 100001203, 100001207, 100001219, 100001227 ]
  for p ∈ primes
    @test 1 < private_key(p) < p
  end
end

@testset "key exchange" begin
  for (p, g) ∈ [ (23, 5), (43, 47),  (1483, 1553), (29501, 2147483647) ]
    alice_privkey = private_key(p)
    bob_privkey = private_key(p)
    alice_pubkey = public_key(p, g, alice_privkey)
    bob_pubkey = public_key(p, g, bob_privkey)
    secret_a = calc_secret(p, bob_pubkey, alice_privkey)
    secret_b = calc_secret(p, alice_pubkey, bob_privkey)
    @test secret_a == secret_b
  end
end

@testset "Exceptions" begin
  @test_throws ArgumentError private_key(65536) # not a prime

  @test_throws ArgumentError check_factor(99)   # not a prime
  @test_throws ArgumentError check_factor(-101) # less than 2

  @test_throws ArgumentError  check_key(101, 102)
end


# NOTE: Can fail due to randomness, but most likely will not,
#       due to pseudo-randomness and the large number chosen
@testset "private key is random" begin
  p = 2147483647
  private_keys = [private_key(p) for _ ∈ 0:5]
  @test length(Set(private_keys)) == length(private_keys)
end
