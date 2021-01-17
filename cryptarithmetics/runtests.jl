using Test

include("./cryptarithmetic_solver.jl")

##
## use ulimit -s unlimited; julia runtests.jl
##


@testset "SEND + MORE = MONEY" begin
  expr = "==(+(SEND, MORE), MONEY)"

  exp = Dict{Char,Integer}('M' => 1,
                           'D' => 7,
                           'Y' => 2,
                           'E' => 5,
                           'R' => 8,
                           'S' => 9,
                           'N' => 6,
                           'O' => 0,
                           ) # one possible solution

  (env, pb) = read_input(expr)
  @time has_sol, sol = solve(env, pb)

  @test has_sol

  for k ∈ keys(exp)
    @test sol[k] == exp[k]
  end
end

@testset "SUN + FUN = SWIM" begin
  expr = "==(+(SUN, FUN), SWIM)"

  exp = Dict{Char,Integer}('M' => 2,
                           'U' => 3,
                           'I' => 7,
                           'W' => 0,
                           'S' => 1,
                           'N' => 6,
                           'F' => 9,
                           ) # one possible solution

  (env, pb) = read_input(expr)
  @time has_sol, sol = solve(env, pb)

  @test has_sol

  for k ∈ keys(exp)
    @test sol[k] == exp[k]
  end
end

@testset "GERALD + DONALD = ROBERT" begin
  expr = "==(+(GERALD, DONALD), ROBERT)"

  exp = Dict{Char,Integer}('B' => 1, 'D' => 5, 'A' => 4, 'L' => 6, 'E' => 9, 'R' => 3, 'G' => 7, 'T' => 0, 'N' => 8, 'O' => 2) # one possible solution
  # ('B' => 3,'D' => 5,'A' => 4,'L' => 8,'E' => 9,'R' => 7,'G' => 1,'T' => 0,'O' => 2,'N' => 6)

  (env, pb) = read_input(expr)
  @time has_sol, sol = solve(env, pb)

  @test has_sol

  for k ∈ keys(exp)
    @test sol[k] == exp[k]
  end
end


@testset "COUNT - COIN = SNUB" begin
  expr = "==(-(COUNT, COIN), SNUB)"

  exp = Dict{Char,Integer}('C' => 1, 'U' => 6, 'B' => 7, 'S' => 9, 'I' => 8, 'T' => 2, 'N' => 5, 'O' => 0) # one possible solution

  (env, pb) = read_input(expr)
  @time has_sol, sol = solve(env, pb)

  for k ∈ keys(exp)
    @test sol[k] == exp[k]
  end
end

@testset "EAT + THAT = APPLE" begin
  expr = "==(+(EAT, THAT), APPLE)"
  exp = Dict{Char,Integer}('P' => 0, 'A' => 1, 'L' => 3, 'H' => 2, 'E' => 8, 'T' => 9)

  (env, pb) = read_input(expr)
  @time has_sol, sol = solve(env, pb)

  for k ∈ keys(exp)
    @test sol[k] == exp[k]
  end
end

@testset "FOO + BAR = ZOO is impossible" begin
  expr = "==(+(FOO, BAR), ZOO)"

  (env, pb) = read_input(expr)
  @time has_sol, sol = solve(env, pb)

  @test !has_sol
  @test sol == nothing
end

@testset "A + A + A + A + A + A + A + A + A + A + A + B == BCC" begin
  expr = "==(+(A, A, A, A, A, A, A, A, A, A, A, B), BCC)"
  exp = Dict{Char,Integer}('A' => 9, 'B' => 1, 'C' => 0)

  (env, pb) = read_input(expr)
  @time has_sol, sol = solve(env, pb)

  for k ∈ keys(exp)
    @test sol[k] == exp[k]
  end
end

@testset "HE + SEES + THE == LIGHT" begin
  expr = "==(+(HE, SEES, THE), LIGHT)"
  exp = Dict{Char,Integer}('E' => 4, 'G' => 2, 'H' => 5, 'I' => 0, 'L' => 1, 'S' => 9, 'T' => 7)
  #                       ('L' => 1,'I' => 0,'H' => 5,'E' => 4,'G' => 2,'S' => 9,'T' => 7)
  (env, pb) = read_input(expr)
  @time has_sol, sol = solve(env, pb)

  for k ∈ keys(exp)
    @test sol[k] == exp[k]
  end
end

@testset "AND + A + STRONG + OFFENSE + AS + A + GOOD == DEFENSE" begin
  expr = "==(+(AND, A, STRONG, OFFENSE, AS, A, GOOD), DEFENSE)"
  exp = Dict{Char,Integer}('A' => 5, 'D' => 3, 'E' => 4, 'F' => 7, 'G' => 8, 'N' => 0, 'O' => 2, 'R' => 1, 'S' => 6, 'T' => 9)

  (env, pb) = read_input(expr)
  @time has_sol, sol = solve(env, pb)

  for k ∈ keys(exp)
    @test sol[k] == exp[k]
  end
end

@testset "A very long expression" begin
  expr = "==(+(THIS, A, FIRE, THEREFORE, FOR, ALL, HISTORIES, I, TELL, A, TALE, THAT, FALSIFIES, ITS, TITLE, TIS, A, LIE, THE, TALE, OF, THE, LAST, FIRE, HORSES, LATE, AFTER, THE, FIRST, FATHERS, FORESEE, THE, HORRORS, THE, LAST, FREE, TROLL, TERRIFIES, THE, HORSES, OF, FIRE, THE, TROLL, RESTS, AT, THE, HOLE, OF, LOSSES, IT, IS, THERE, THAT, SHE, STORES, ROLES, OF, LEATHERS, AFTER, SHE, SATISFIES, HER, HATE, OFF, THOSE, FEARS, A, TASTE, RISES, AS, SHE, HEARS, THE, LEAST, FAR, HORSE, THOSE, FAST, HORSES, THAT, FIRST, HEAR, THE, TROLL, FLEE, OFF, TO, THE, FOREST, THE, HORSES, THAT, ALERTS, RAISE, THE, STARES, OF, THE, OTHERS, AS, THE, TROLL, ASSAILS, AT, THE, TOTAL, SHIFT, HER, TEETH, TEAR, HOOF, OFF, TORSO, AS, THE, LAST, HORSE, FORFEITS, ITS, LIFE, THE, FIRST, FATHERS, HEAR, OF, THE, HORRORS, THEIR, FEARS, THAT, THE, FIRES, FOR, THEIR, FEASTS, ARREST, AS, THE, FIRST, FATHERS, RESETTLE, THE, LAST, OF, THE, FIRE, HORSES, THE, LAST, TROLL, HARASSES, THE, FOREST, HEART, FREE, AT, LAST, OF, THE, LAST, TROLL, ALL, OFFER, THEIR, FIRE, HEAT, TO, THE, ASSISTERS, FAR, OFF, THE, TROLL, FASTS, ITS, LIFE, SHORTER, AS, STARS, RISE, THE, HORSES, REST, SAFE, AFTER, ALL, SHARE, HOT, FISH, AS, THEIR, AFFILIATES, TAILOR, A, ROOFS, FOR, THEIR, SAFE), FORTRESSES)"
  exp = Dict{Char,Integer}('A' => 1, 'E' => 0, 'F' => 5, 'H' => 8, 'I' => 7, 'L' => 2, 'O' => 6, 'R' => 3, 'S' => 4, 'T' => 9)

  (env, pb) = read_input(expr)
  @time has_sol, sol = solve(env, pb)

  for k ∈ keys(exp)
    @test sol[k] == exp[k]
  end

end


#   9.593870 seconds (34.26 M allocations: 2.730 GiB, 9.80% gc time)
# Test Summary:       | Pass  Total
# SEND + MORE = MONEY |    9      9

#   8.657626 seconds (33.94 M allocations: 2.703 GiB, 17.85% gc time)
# Test Summary:    | Pass  Total
# SUN + FUN = SWIM |    8      8

#   6.926719 seconds (32.34 M allocations: 2.701 GiB, 13.43% gc time)
# Test Summary:            | Pass  Total
# GERALD + DONALD = ROBERT |   11     11

#   6.884141 seconds (31.45 M allocations: 2.631 GiB, 12.66% gc time)
# Test Summary:       | Pass  Total
# COUNT - COIN = SNUB |    8      8

#   3.208110 seconds (23.20 M allocations: 2.420 GiB, 22.03% gc time)
# Test Summary:      | Pass  Total
# EAT + THAT = APPLE |    6      6

#  25.688375 seconds (66.68 M allocations: 3.608 GiB, 6.73% gc time)
# Test Summary:                 | Pass  Total
# FOO + BAR = ZOO is impossible |    2      2

#   9.358140 seconds (77.95 M allocations: 4.817 GiB, 22.79% gc time)
# Test Summary:                                        | Pass  Total
# A + A + A + A + A + A + A + A + A + A + A + B == BCC |    3      3

#   3.442288 seconds (24.61 M allocations: 2.481 GiB, 22.70% gc time)
# Test Summary:            | Pass  Total
# HE + SEES + THE == LIGHT |    7      7

#  25.646390 seconds (183.92 M allocations: 9.432 GiB, 29.04% gc time)
# Test Summary:                                         | Pass  Total
# AND + A + STRONG + OFFENSE + AS + A + GOOD == DEFENSE |   10     10

# 59.449906 seconds (809.69 M allocations: 37.977 GiB, 18.94% gc time)
# Test Summary:          | Pass  Total
# A very long expression |   10     10
