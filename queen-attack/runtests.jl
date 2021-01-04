using Test

include("./queen_attack.jl")

@testset "invalid position" begin
  # @test Queen{Int32}(Int32(2), Int32(2))
  @test_throws ArgumentError Queen{Int32}(Int32(0), Int32(-10))
  @test_throws ArgumentError Queen{Int32}(Int32(9), Int32(10))
  @test_throws ArgumentError Queen{Int32}(Int32(1), Int32(10))
end

@testset "cannot attack" begin
  T = Int32
  q = Queen{T}(T(2), T(2))

  @test !can_attack(q, Queen{T}(T(4), T(3)))
  @test !can_attack(q, Queen{T}(T(4), T(8)))
  @test !can_attack(q, Queen{T}(T(8), T(3)))
  @test !can_attack(q, Queen{T}(T(3), T(8)))

  @test_throws ArgumentError can_attack(q, Queen{T}(T(2), T(2))) # same pos.
end

@testset "can attack /1" begin
  T = Int32
  q = Queen{T}(T(2), T(2))

  @test can_attack(q, Queen{T}(T(8), T(8)))
  @test can_attack(q, Queen{T}(T(1), T(1)))
  @test can_attack(q, Queen{T}(T(1), T(3)))
  @test can_attack(q, Queen{T}(T(3), T(1)))

  @test can_attack(q, Queen{T}(T(3), T(2)))
  @test can_attack(q, Queen{T}(T(2), T(5)))
end

@testset "can attack /2" begin
  T = Int32
  q = Queen{T}(T(3), T(1))

  @test can_attack(q, Queen{T}(T(3), T(8)))
  @test can_attack(q, Queen{T}(T(3), T(2)))
  @test can_attack(q, Queen{T}(T(8), T(1)))
  @test can_attack(q, Queen{T}(T(1), T(1)))

  @test can_attack(q, Queen{T}(T(8), T(6)))
  @test can_attack(q, Queen{T}(T(5), T(3)))
  @test can_attack(q, Queen{T}(T(1), T(3)))
end
