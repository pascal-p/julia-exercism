using Test

include("react.jl"); const T = Int64

@testset "InputCell" begin
  @testset "InputCell init" begin
    input = InputCell{T}(10)
    @test input.value == 10
  end

  @testset "InputCell update" begin
    input = InputCell{T}(10)
    input.value = 42

    @test input.value == 42
  end
end

@testset "ComputeCell" begin
  @testset "ComputeCell initial value" begin
    input = InputCell{T}(41)
    output = ComputeCell{T}([input], inputs -> inputs[1] + 1)

    @test input.value == 41
    @test output.value == 42
  end

  @testset "ComputeCells take inputs in right order" begin
    one = InputCell{T}(1)
    two = InputCell{T}(2)
    output = ComputeCell{T}([one, two],
                            inputs -> inputs[1] + inputs[2] * 10)

    @test output.value == 21
  end

  @testset "ComputeCells update value when dependencies are changed" begin
    one = InputCell{T}(1)
    two = InputCell{T}(2)
    output = ComputeCell{T}([one, two],
                            inputs -> inputs[1] + inputs[2] * 10)

    @test output.value == 21

    one.value = 5
    @test output.value == 25
  end

  @testset "ComputeCells can depend on other ComputeCells" begin
    inp = InputCell{T}(1)
    times_2 = ComputeCell{T}([inp], inputs -> inputs[1] * 2)
    times_30 = ComputeCell{T}([inp], inputs -> inputs[1] * 30)
    output = ComputeCell{T}([times_2, times_30],
                            inputs-> inputs[1] + inputs[2])

    @test output.value == 32
    inp.value = 10
    @test output.value == 320
  end
end

@testset "ComputeCell with callbacks" begin
  @testset "ComputeCells fire callbacks" begin
    inp = InputCell{T}(1)
    output = ComputeCell{T}([inp],
                            inputs-> inputs[1] + 1)
    obs = []
    cb = value -> push!(obs, value)
    add_callback(output, cb)

    inp.value = 3
    @test obs[end] == 4
    @test output.value == 4
  end

  @testset "ComputeCells only fire callbacks on change" begin
    inp = InputCell{T}(1)
    output = ComputeCell{T}([inp],
                            inputs-> inputs[1] < 3 ? 111 : 222)
    obs = []
    cb = value -> push!(obs, value)
    add_callback(output, cb)

    inp.value = 2
    @test length(obs) == 0

    inp.value = 3
    @test obs[end] == 222
  end
end
