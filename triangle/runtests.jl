using Test

include("./triangle.jl")

@testset "equilateral" begin
  @testset "all sides are equal" begin
    @test equilateral((2, 2, 2))
  end

  @testset "any side is unequal" begin
    @test !equilateral((2, 3, 2))
  end

  @testset "no sides are equal" begin
    @test !equilateral((5, 4, 6))
  end

  @testset "sides can be float" begin
    @test equilateral((√2, √2, √2))
  end

  @testset "all zero sides is not a triangle" begin
    @test !equilateral((0, 0, 0))
  end
end


@testset "isosceles" begin
  @testset "last two sides are equal" begin
    @test isosceles((3, 4, 4))
  end

  @testset  "first two sides are equal" begin
    @test isosceles((4, 4, 3))
  end

  @testset "first and last sides are equal" begin
    @test isosceles((4, 3, 4))
  end

  @testset "equilateral triangles are also isosceles" begin
    @test isosceles((4, 4, 4))
  end

  @testset "no sides are equal(self)" begin
    @test !isosceles((2, 3, 4))
  end

  @testset "first triangle inequality violation" begin
    @test !isosceles((1, 1, 3))
  end

  @testset "second triangle inequality violation" begin
    @test !isosceles((1, 3, 1))
  end

  @testset "third triangle inequality violation" begin
    @test !isosceles((3, 1, 1))
  end

  @testset "sides may be floats" begin
    @test isosceles((0.5, 0.4, 0.5))
  end
end

@testset "scalene" begin
  @testset "no sides are equal" begin
    @test scalene((5, 4, 6))
  end

  @testset "all sides are equal" begin
    @test !scalene((4, 4, 4))
  end

  @testset "two_sides_are_equal" begin
    @test !scalene((4, 4, 3))
  end

  @testset "may not violate triangle inequality" begin
    @test !scalene((7, 3, 2))
  end

  @testset "sides_may_be_floats" begin
    @test scalene((0.5, 0.4, 0.6))
  end
end
