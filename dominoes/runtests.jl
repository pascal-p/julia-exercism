using Test

include("dominoes.jl")

@testset "dominoes" begin

  @testset "empty input" begin
    @test can_chain([]) == []
  end

  @testset "singleton" begin
    @test can_chain([(TT(1), TT(1))]) == [(TT(1), TT(1))]
  end

  @testset "singleton that cannot be chainned" begin
    @test isnothing(can_chain([(TT(1), TT(2))]))
  end

  @testset "2 element list" begin
    @test can_chain([(TT(1), TT(2)), (TT(1), TT(2))]) == [(TT(1), TT(2)), (TT(2), TT(1))]
  end

  @testset "2 element list that cannot be chainned" begin
    @test isnothing(can_chain([(TT(1), TT(2)), (TT(1), TT(3))]))
  end

  @testset "3 element list" begin
    @test can_chain([(TT(1), TT(2)), (TT(3), TT(1)), (TT(2), TT(3))]) == [(TT(1), TT(2)), (TT(2), TT(3)), (TT(3), TT(1))]
  end

  @testset "can reverse" begin
    @test can_chain([(TT(1), TT(2)), (TT(1), TT(3)), (TT(2), TT(3))]) == [(TT(1), TT(2)), (TT(2), TT(3)), (TT(3), TT(1))]
  end

  @testset "3 element list that cannot be chainned" begin
    @test isnothing(can_chain([(TT(1), TT(2)), (TT(4), TT(1)), (TT(2), TT(3))]))
  end

  @testset "test disconnected single isolated" begin
    @test isnothing(can_chain([(TT(1), TT(2)), (TT(2), TT(3)), (TT(3), TT(1)), (TT(4), TT(4))]))
  end

  @testset "test need backtrack" begin
    @test can_chain([(TT(1), TT(2)), (TT(2), TT(3)), (TT(3), TT(1)), (TT(2), TT(4)), (TT(2), TT(4))]) ==
      [(TT(1), TT(2)), (TT(2), TT(4)), (TT(4), TT(2)), (TT(2), TT(3)), (TT(3), TT(1))]
  end

  @testset "test separate loops" begin
    @test can_chain([(TT(1), TT(2)), (TT(2), TT(3)), (TT(3), TT(1)), (TT(1), TT(1)), (TT(2), TT(2)), (TT(3), TT(3))]) ==
      [(0x01, 0x02), (0x02, 0x02), (0x02, 0x03), (0x03, 0x03), (0x03, 0x01), (0x01, 0x01)]
  end

  @testset "9 elements" begin
    @test can_chain([(TT(1), TT(2)), (TT(5), TT(3)), (TT(3), TT(1)), (TT(1), TT(2)),
                     (TT(2), TT(4)), (TT(1), TT(6)), (TT(2), TT(3)), (TT(3), TT(4)),
                     (TT(5), TT(6))]) ==
      [(0x01, 0x02), (0x02, 0x04), (0x04, 0x03), (0x03, 0x01), (0x01, 0x02), (0x02, 0x03),
       (0x03, 0x05), (0x05, 0x06), (0x06, 0x01)]
  end
end
