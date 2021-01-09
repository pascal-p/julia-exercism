using Test

include("./gauss_queen.jl")

# row: 1, col: 1
@testset "4 queens - from pos. (1, 1) " begin
  q = Queen(Int32(4))

  @test !queen_1sol(q; c=Int32(1))
end

# row: 1, col: 2

"""
+---+---+---+---+
|   | Q |   |   |
+---+---+---+---+
|   |   |   | Q |
+---+---+---+---+
| Q |   |   |   |
+---+---+---+---+
|   |   | Q |   |
+---+---+---+---+
"""

@testset "4 queens - from pos. (1, 2) " begin
  q = Queen(Int32(4))

  @test queen_1sol(q; c=Int32(2))

end


"""
+---+---+---+---+---+
| Q |   |   |   |   |
+---+---+---+---+---+
|   |   | Q |   |   |
+---+---+---+---+---+
|   |   |   |   | Q |
+---+---+---+---+---+
|   | Q |   |   |   |
+---+---+---+---+---+
|   |   |   | Q |   |
+---+---+---+---+---+
"""

@testset "5 queens - (1, 1) " begin
  q = Queen(Int32(5))

  @test queen_1sol(q; c=Int32(1))
end


"""
+---+---+---+---+---+
|   | Q |   |   |   |
+---+---+---+---+---+
|   |   |   | Q |   |
+---+---+---+---+---+
| Q |   |   |   |   |
+---+---+---+---+---+
|   |   | Q |   |   |
+---+---+---+---+---+
|   |   |   |   | Q |
+---+---+---+---+---+
"""

@testset "5 queens - (1, 2) " begin
  q = Queen(Int32(5))

  @test queen_1sol(q; c=Int32(2))
end


"""
+---+---+---+---+---+---+---+---+
| Q |   |   |   |   |   |   |   |
+---+---+---+---+---+---+---+---+
|   |   |   |   | Q |   |   |   |
+---+---+---+---+---+---+---+---+
|   |   |   |   |   |   |   | Q |
+---+---+---+---+---+---+---+---+
|   |   |   |   |   | Q |   |   |
+---+---+---+---+---+---+---+---+
|   |   | Q |   |   |   |   |   |
+---+---+---+---+---+---+---+---+
|   |   |   |   |   |   | Q |   |
+---+---+---+---+---+---+---+---+
|   | Q |   |   |   |   |   |   |
+---+---+---+---+---+---+---+---+
|   |   |   | Q |   |   |   |   |
+---+---+---+---+---+---+---+---+
"""

@testset "8 queens - (1, 1) " begin
  q = Queen(Int32(8))
  r = queen_1sol(q; c=Int32(1))

  @test r
  @test q.vq == Int32[1, 5, 8, 6, 3, 7, 2, 4]
end


"""
+---+---+---+---+---+---+---+---+
|   | Q |   |   |   |   |   |   |
+---+---+---+---+---+---+---+---+
|   |   |   | Q |   |   |   |   |
+---+---+---+---+---+---+---+---+
|   |   |   |   |   | Q |   |   |
+---+---+---+---+---+---+---+---+
|   |   |   |   |   |   |   | Q |
+---+---+---+---+---+---+---+---+
|   |   | Q |   |   |   |   |   |
+---+---+---+---+---+---+---+---+
| Q |   |   |   |   |   |   |   |
+---+---+---+---+---+---+---+---+
|   |   |   |   |   |   | Q |   |
+---+---+---+---+---+---+---+---+
|   |   |   |   | Q |   |   |   |
+---+---+---+---+---+---+---+---+
"""

@testset "8 queens - (1, 2) " begin
  q = Queen(Int32(8))
  r = queen_1sol(q; c=Int32(2))

  @test r
  @test q.vq == Int32[2, 4, 6, 8, 3, 1, 7, 5]
end

for (nq, n) ∈ [
               (3, 0), (4, 2), (5, 10), (6, 4),
               (7, 40), (8, 92), (9, 352),
               (10, 724), (11, 2680), (12, 14_200),
               (13, 73_712), (14, 365_596)
               ]

  @testset "$(nq) queens - all sols $(n)" begin
    q = Queen(Int32(nq))
    @test @time queen_sols(q) == Int32(n)
  end
end


#
# q = Queen(Int32(4))
# Queen(4, Int32[-1939537424, 32756, -1939537392, 32756])
#


# Test Summary:                | Pass  Total
# 4 queens - from pos. (1, 1)  |    1      1

# Test Summary:                | Pass  Total
# 4 queens - from pos. (1, 2)  |    1      1

# Test Summary:      | Pass  Total
# 5 queens - (1, 1)  |    1      1

# Test Summary:      | Pass  Total
# 5 queens - (1, 2)  |    1      1

# Test Summary:      | Pass  Total
# 8 queens - (1, 1)  |    2      2

# Test Summary:      | Pass  Total
# 8 queens - (1, 2)  |    2      2

#   0.034994 seconds (81.36 k allocations: 4.272 MiB)
# Test Summary:         | Pass  Total
# 3 queens - all sols 0 |    1      1

#   0.002217 seconds (48 allocations: 2.766 KiB)
# Test Summary:         | Pass  Total
# 4 queens - all sols 2 |    1      1

#   0.000008 seconds (3 allocations: 80 bytes)
# Test Summary:          | Pass  Total
# 5 queens - all sols 10 |    1      1

#   0.000036 seconds (3 allocations: 80 bytes)
# Test Summary:         | Pass  Total
# 6 queens - all sols 4 |    1      1

#   0.000093 seconds (3 allocations: 80 bytes)
# Test Summary:          | Pass  Total
# 7 queens - all sols 40 |    1      1

#   0.000368 seconds (3 allocations: 80 bytes)
# Test Summary:          | Pass  Total
# 8 queens - all sols 92 |    1      1

#   0.001692 seconds (3 allocations: 80 bytes)
# Test Summary:           | Pass  Total
# 9 queens - all sols 352 |    1      1

#   0.009028 seconds (217 allocations: 3.422 KiB)
# Test Summary:            | Pass  Total
# 10 queens - all sols 724 |    1      1

#   0.046410 seconds (2.17 k allocations: 33.984 KiB)
# Test Summary:             | Pass  Total
# 11 queens - all sols 2680 |    1      1

#   0.270245 seconds (13.69 k allocations: 213.984 KiB)
# Test Summary:              | Pass  Total
# 12 queens - all sols 14200 |    1      1

#   1.655545 seconds (73.20 k allocations: 1.117 MiB)
# Test Summary:              | Pass  Total
# 13 queens - all sols 73712 |    1      1

#  11.284226 seconds (365.09 k allocations: 5.571 MiB, 0.03% gc time)
# Test Summary:               | Pass  Total
# 14 queens - all sols 365596 |    1      1
