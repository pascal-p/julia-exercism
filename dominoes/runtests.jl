using Test

include("dominoes.jl")

@testset "dominoes" begin

  @testset "empty input" begin
    @test can_chain([]) == []
  end

  @testset "singleton" begin
    @test can_chain([(TT(1), TT(1))]) == [(TT(1), TT(1))]
  end

   @testset "singleton that cannot be chainned " begin
     @test can_chain([(TT(1), TT(2))]) == nothing
  end
end
