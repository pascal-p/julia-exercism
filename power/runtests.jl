using Test

include("power.jl")
for (fn_name, power_fn) in [
                            ("std_power", std_power),
                            ("fast_rec_power", fast_power_rec),
                            ("fast_power", fast_power) ]

  @testset "basics $(fn_name)" begin
    @test power_fn(2, 0)[1] == 1
    @test power_fn(2, 1)[1] == 2
    @test power_fn(1, 2)[1] == 1
    @test power_fn(1, 10)[1] == 1

    @test power_fn(1, 10_000_000)[1] == 1
    @test power_fn(0, 10_000_000)[1] == 0
    @test power_fn(3, 2)[1] == 9
    @test power_fn(16, 2)[1] == 256

    @test power_fn(5, 3)[1] == 125
    @test power_fn(-5, 3)[1] == -125

    @test power_fn(6, 3)[1] == 216
    @test power_fn(-6, 3)[1] == -216

    @test power_fn(-7, 6)[1] == 117649
  end

  @testset "correctness $(fn_name)" begin
    @test power_fn(6, 20)[1] == 3656158440062976

    @test power_fn(UInt128(2), 64)[1] == 18446744073709551616
    @test power_fn(BigInt(2), 128)[1] == 340282366920938463463374607431768211456
  end

  @testset "Exceptions" begin
    @test_throws ArgumentError power_fn(2, -3)
    @test_throws ArgumentError power_fn(0, 0)
  end

end

# julia> @time std_power(BigInt(2), 128)
#   0.002449 seconds (740 allocations: 33.492 KiB)
# (340282366920938463463374607431768211456, 128)

# julia> @time fast_power_rec(BigInt(2), 128)
#   0.009399 seconds (9.26 k allocations: 516.304 KiB)
# (340282366920938463463374607431768211456, 7)

# julia> @time fast_power(BigInt(2), 128)
#   0.000016 seconds (24 allocations: 424 bytes)
# (340282366920938463463374607431768211456, 7)
