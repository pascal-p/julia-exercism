using Test

import Random

include("robot-name.jl")

# Random names means a risk of collisions.
const history = Set{String}()

isname(x) = occursin(r"^[A-Z]{2}[0-9]{3}$", x)

@time @testset "one robot" begin
  global r1 = Robot()
  push!(history, name(r1))

  @testset "name of robot is valid" begin
    @test isname(name(r1))
  end

  @testset "names of robot instance are valid and unique in history" begin
    # @testset sets the same seed every time for reproducibility, but we're
    # undoing that deliberately with Random.seed!() to increase the chance
    # of seeing collisions.
    Random.seed!()
    for _ ∈ 1:1000
      reset!(r1)

      @test isname(name(r1))
      @test !in(name(r1), history)

      push!(history, name(r1))
    end
  end
end

@time @testset "two robots" begin
  global r2 = Robot()
  global r3 = Robot()

  @testset "names of robots are valid" begin
    @test isname(name(r2))
    @test isname(name(r3))
  end

  @testset "names of robots are not equal" begin
    @test name(r2) != name(r3)
  end

  @testset "names of both robots are unique in history" begin
    @test !in(name(r2), history)
    @test !in(name(r3), history)
  end

  push!(history, name(r2))
  push!(history, name(r3))
end

@time @testset "many robots" begin
  Random.seed!()
  robots = Robot[]

  for i in 1:50_000  # also tried 100_000 and 1_000_000
    push!(robots, Robot())

    @testset "name of robot is valid and unique in history" begin
      @test isname(name(robots[i]))
      @test !in(name(robots[i]), history)
    end

    push!(history, name(robots[i]))
  end

  @testset "fresh names of reset robots are valid and unique in history" begin
    Random.seed!()
    for r in robots
      reset!(r)
      @test isname(name(r))
      @test !in(name(r), history)
      push!(history, name(r))
    end
  end
end

#
# Test Summary: | Pass  Total
# one robot     | 2001   2001
#   0.171353 seconds (443.05 k allocations: 58.777 MiB, 2.31% gc time, 83.24% compilation time)

# Test Summary: | Pass  Total
# two robots    |    5      5
#   0.002884 seconds (399 allocations: 202.594 KiB, 88.73% compilation time)

# Test Summary: |   Pass   Total  # 100_000
# many robots   | 400000  400000
#   6.370578 seconds (10.20 M allocations: 10.280 GiB, 18.41% gc time)

# Test Summary: |   Pass   Total  # 200_000
# many robots   | 800000  800000
#  16.421829 seconds (22.80 M allocations: 25.056 GiB, 25.06% gc time)

# Test Summary: |   Pass   Total
# many robots   | 200000  200000
#   2.869089 seconds (4.91 M allocations: 4.782 GiB, 15.77% gc time)
