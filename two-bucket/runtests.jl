using Test

include("./two_bucket.jl")

@testset "b1(3L) and b2(5L) make 1L / :one" begin
  @test measure(3, 5, 1, :one) == (4, :one, 5)
end

@testset "b1(3L) and b2(5L) make 4L" begin
  @test measure(5, 3, 4, :one) == (6, :one, 3)
  @test measure(5, 3, 4, :two) == (8, :one, 0)
end

@testset "b1(3L) and b2(5L) make 7L" begin
  @test measure(5, 3, 7, :one) == (6, :two, 4)
  @test measure(5, 3, 7, :two) == (10, :two, 5)
end

@testset "b1(3L) and b2(5L) make 1L / :two" begin
  @test measure(3, 5, 1, :two) == (8, :two, 3)
end

@testset "b1(7L) and b2(11L) make 2L / :one" begin
  @test measure(7,11, 2, :one) == (14, :one, 11)
end

@testset "b1(7L) and b2(11L) make 2L / :two" begin
  @test measure(7, 11, 2, :two) == (18, :two, 7)
end

@testset "b1(1L) and b2(3L) make 3L / :two" begin
  @test measure(1, 3, 3, :two) == (1, :two, 0)
end

@testset "b1(1L) and b2(3L) make 2L / :two" begin
  @test measure(1, 3, 2, :two) == (2, :two, 1)
end

@testset "b1(6L) and b2(15L) make 4L / :one / impossible" begin
  @test_throws ArgumentError measure(6, 15, 2, :one)
end

@testset "b1(6L) and b2(15L) make 9L" begin
  @test measure(6, 15, 9, :one) == (10, :two, 0)
  @test measure(6, 15, 9, :two) == (2, :two, 6)
end

@testset "b1(6L) and b2(15L) make 18L" begin
  @test measure(6, 15, 18, :one) == (6, :two, 3)
  @test measure(6, 15, 18, :two) == (8, :two, 6)
end

@testset "b1(2L) and b2(15L) make 1L" begin
  @test measure(2, 15, 1, :one) == (16, :one, 15)
  @test measure(2, 15, 1, :two) == (14, :two, 2)
end

@testset "b1(2L) and b2(15L) make 17L" begin
  @test measure(2, 15, 17, :one) == (2, :both, 17)
  @test measure(2, 15, 17, :two) == (2, :both, 17)
end
