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

  @testset "ComputeCells do not report already reported values" begin
    inp = InputCell{T}(1)
    output = ComputeCell{T}([inp],
                            inputs-> inputs[1] + 1)
    obs = []
    cb = value -> push!(obs, value)
    add_callback(output, cb)

    inp.value = 2
    @test obs[end] == 3

    inp.value = 3
    @test obs[end] == 4
  end

  @testset "ComputeCells can fire from multiple cells" begin
    inp = InputCell{T}(1)
    inc = ComputeCell{T}([inp],
                         inputs-> inputs[1] + 1)
    dec = ComputeCell{T}([inp],
                         inputs-> inputs[1] - 1)

    cb1_obs, cb2_obs = [], []
    cb1 = value -> push!(cb1_obs, value)
    cb2 = value -> push!(cb2_obs, value)

    add_callback(inc, cb1)
    add_callback(dec, cb2)
    # add_callback.(output, [cb1 cb2])

    inp.value = 10
    @test cb1_obs[end] == 11
    @test cb2_obs[end] == 9
  end

  @testset "ComputeCells callbacks can be added and removed" begin
    inp = InputCell{T}(1)
    inc = ComputeCell{T}([inp],
                         inputs-> inputs[1] + 1)

    cb1_obs, cb2_obs, cb3_obs = [], [], []
    cb1 = value -> push!(cb1_obs, value)
    cb2 = value -> push!(cb2_obs, value)
    cb3 = value -> push!(cb3_obs, value)

    add_callback(inc, cb1)
    add_callback(inc, cb2)

    inp.value = 31
    @test cb1_obs[end] == 32
    @test cb2_obs[end] == 32

    remove_callback(inc, cb1)
    add_callback(inc, cb3)

    inp.value = 41
    @test cb2_obs[end] == 42
    @test cb3_obs[end] == 42

    @test length(cb1_obs) == 1
  end

  @testset "ComputeCells: removing callback mulitple times" begin
    inp = InputCell{T}(1)
    inc = ComputeCell{T}([inp],
                         inputs-> inputs[1] + 1)
    cb1_obs, cb2_obs = [], []
    cb1 = value -> push!(cb1_obs, value)
    cb2 = value -> push!(cb2_obs, value)

    add_callback(inc, cb1)
    add_callback(inc, cb2)
    remove_callback(inc, cb1)
    remove_callback(inc, cb1)
    remove_callback(inc, cb1)

    inp.value = 41
    @test length(cb1_obs) == 0
    @test cb2_obs[end] == 42
  end

  @testset "ComputeCells: callbacks should only be called once" begin
    # Guard against incorrect implementations which call a callback
    # function multiple times when multiple dependencies change
    inp = InputCell{T}(1)
    inc = ComputeCell{T}([inp],
                         inputs-> inputs[1] + 1)
    dec1 = ComputeCell{T}([inp],
                          inputs-> inputs[1] - 1)
    dec2 = ComputeCell{T}([dec1],
                          inputs-> inputs[1] - 1)
    output = ComputeCell{T}([inc, dec2],
                            inputs-> inputs[1] * inputs[2])
    obs = []
    cb = value -> push!(obs, value)

    add_callback(output, cb)

    inp.value = 4
    @test obs[end] == 10
  end

  @testset "ComputeCells: callbacks not called so long as the output is not changed" begin
    # Guard against incorrect implementations which call callbacks
    # if dependencies change but output value doesn't change
    inp = InputCell{T}(1)
    inc = ComputeCell{T}([inp],
                         inputs-> inputs[1] + 1)
    dec = ComputeCell{T}([inp],
                         inputs-> inputs[1] - 1)
    always_2 = ComputeCell{T}([inc, dec],
                              inputs-> inputs[1] - inputs[2])
    obs = []
    cb = value -> push!(obs, value)

    add_callback(always_2, cb)
    inp.value = 2
    inp.value = 3
    inp.value = 4
    inp.value = 5

    @test length(obs) == 0
  end
end
