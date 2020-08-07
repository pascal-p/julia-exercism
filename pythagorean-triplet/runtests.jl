# canonical data version 1.0.0

using Test
include("pythagorean-triplet.jl")

@testset "triplets whose sum is 12" begin
    @test pythagorean_triplets(12) == [(3, 4, 5)]
end

@testset "triplets whose sum is 108" begin
    @test pythagorean_triplets(108) == [(27, 36, 45)]
end

@testset "triplets whose sum is 1000" begin
    @test pythagorean_triplets(1000) == [(200, 375, 425)]
end

@testset "triplets whose sum is 1001" begin
    @test pythagorean_triplets(1001) == []
end

@testset "returns all matching triplets" begin
    @test pythagorean_triplets(90) == [(9, 40, 41), (15, 36, 39)]
end

@testset "several matching triplets" begin
    @test pythagorean_triplets(840) == [
        (40, 399, 401),
        (56, 390, 394),
        (105, 360, 375),
        (120, 350, 370),
        (140, 336, 364),
        (168, 315, 357),
        (210, 280, 350),
        (240, 252, 348),
    ]
end

@testset "triplets for large number" begin

    @test pythagorean_triplets(30_000) == [
        (1200, 14375, 14425),
        (1875, 14000, 14125),
        (5000, 12000, 13000),
        (6000, 11250, 12750),
        (7500, 10000, 12500),
    ]

    @test pythagorean_triplets(50_000) == [
        (10000, 18750, 21250),
    ]

    @test pythagorean_triplets(100_000) == [
        (20000, 37500, 42500),
        (21875, 36000, 42125),
    ]

    @test pythagorean_triplets(100_256) == [
        (13728, 42175, 44353),
        (18798, 38560, 42898),
    ]

end
