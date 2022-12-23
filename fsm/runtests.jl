using Test

include("./fsm.jl")

@testset "States" begin
  for state ∈ (Ready, Waiting, Dispense, Refunding, Exit)
    @test genstate(state) !== nothing
  end

  for state ∈ (Ready, Waiting, Dispense, Refunding)
    @eval begin
      @test !quitting($state())
    end
  end

  @test quitting(Exit())
end


@testset "Ready -> Waiting by :deposit transition" begin
  ready_st = genstate(Ready)

  @test :deposit ∈ keys(ready_st.transitions) |> collect
  @test next_state!(ready_st, :deposit) == Waiting
end


@testset "Ready undefined transition" begin
  ready_st = genstate(Ready)
  @test next_state!(ready_st, :foo) === nothing
end


@testset "From Ready to Exit" begin
  ready_st = genstate(Ready)
  next_st = next_state!(ready_st, :deposit)
  @test next_st == Waiting

  waiting_st = genstate(next_st)
  next_st = next_state!(waiting_st, :select)
  @test next_st == Dispense

  dispense_st = genstate(next_st)
  next_st = next_state!(dispense_st, :remove)
  @test next_st == Ready

  ready_st = genstate(next_st)
  next_st = next_state!(ready_st, :quit)
  @test next_st == Exit
end
