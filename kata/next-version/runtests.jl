using Test

include("next-version.jl")

@testset "base cases" begin
  base_version = "1.2.3"

  for cv ∈ 3:8
    @test nextversion(string(base_version[1:end-1], "$(cv)")) == string(base_version[1:end-1], "$(cv + 1)")
  end

  @test nextversion("1.2.9") ==  "1.3.0"
  @test nextversion("0.9.9") ==  "1.0.0"

  @test nextversion("1") ==  "2"
  @test nextversion("1.2.3.4.5.6.7.8") == "1.2.3.4.5.6.7.9"

  @test (nextversion ∘ nextversion)("1.2.3.4.5.6.7.9") == "1.2.3.4.5.6.8.1"

  @test nextversion("9.9") == "10.0"

  # for ix ∈ 1:100
  @test nextversion("1.2.3.4.5.6.7.8") == "1.2.3.4.5.6.7.9" # 1
  @test nextversion("1.2.3.4.5.6.7.9") == "1.2.3.4.5.6.8.0" # 2

  for ix ∈ 0:8
    @test nextversion(string("1.2.3.4.5.6.8.", "$(ix)")) == string("1.2.3.4.5.6.8.", "$(ix + 1)")
  end
  @test nextversion("1.2.3.4.5.6.8.9") == string("1.2.3.4.5.6.9.0")

  for ix ∈ 0:8
    @test nextversion(string("1.2.3.4.5.6.9.", "$(ix)")) == string("1.2.3.4.5.6.9.", "$(ix + 1)")
  end
  @test nextversion("1.2.3.4.5.6.9.9") == string("1.2.3.4.5.7.0.0")

  for ix ∈ 0:8
    @test nextversion(string("1.2.3.4.5.7.0.", "$(ix)")) == string("1.2.3.4.5.7.0.", "$(ix + 1)")
  end
  @test nextversion("1.2.3.4.5.7.0.9") == string("1.2.3.4.5.7.1.0")

  for ix ∈ 0:8
    @test nextversion(string("1.2.3.4.5.7.1.", "$(ix)")) == string("1.2.3.4.5.7.1.", "$(ix + 1)")
  end
  @test nextversion("1.2.3.4.5.7.1.9") == string("1.2.3.4.5.7.2.0")
end

@testset "exception" begin
  @test_throws ArgumentError nextversion("foo")

  @test_throws ArgumentError nextversion(:bar)

  @test_throws ArgumentError nextversion(1.2)

  @test_throws ArgumentError nextversion(true)
end
