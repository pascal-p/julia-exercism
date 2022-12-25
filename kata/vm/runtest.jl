using Base: end_base_include
using Test

include("vm.jl")

@testset "constructor/show" begin
  @test VM() |> string == "0.0.1"
  @test VM("0.0.0") |> string == "0.0.0"
  @test VM("10.2.63") |> string == "10.2.63"

  @test VM("10.2.63.100.200") |> string == "10.2.63"

  # what is the limit?

  @test_throws AssertionError VM("a;b.c")
  @test_throws ArgumentError VM(true)
  @test_throws ArgumentError VM(100)
end

@testset "more on constructor" begin
  @test VM() |> string == "0.0.1"
  @test VM("70") |> string == "70.0.0"

  @test VM("70.8") |> string == "70.8.0"
  @test VM("70.8.15") |> string == "70.8.15"
  @test VM("72.8.6") |> string == "72.8.6"
end

@testset "major" begin
  sv = "1.2.3"
  vm = VM(sv)
  @test major!(vm) |> string == "2.0.0"

  vm = VM(sv)
  @test (major! ∘ major!)(vm) |> string == "3.0.0"
end

@testset "minor" begin
  sv = "1.2.3"
  vm = VM(sv)
  @test minor!(vm) |> string == "1.3.0"

  vm = VM(sv)
  @test (minor! ∘ minor!)(vm) |> string == "1.4.0"
end

@testset "patch" begin
  sv = "1.2.3"
  vm = VM(sv)
  @test patch!(vm) |> string == "1.2.4"

  vm = VM(sv)
  @test (patch! ∘ patch!)(vm) |> string == "1.2.5"
end

@testset "combine major, minor patch and rollback/1" begin
  sv = "1.2.3"
  vm = VM(sv)

  @test_throws ArgumentError rollback(vm)

  @test (major! ∘ minor! ∘ patch!)(vm) |> string == "2.0.0"
  @test (release ∘ rollback)(vm) == "1.3.0"
  @test (release ∘ rollback)(vm) == "1.2.4"
  @test (release ∘ rollback)(vm) == sv
end

@testset "combine major, minor, patch and rollback/2" begin
  sv = "10.2.3"
  vm = VM(sv)

  @test_throws ArgumentError rollback(vm)

  @test (release ∘ major!)(vm) == "11.0.0"
  @test (release ∘ minor!)(vm) == "11.1.0"
  @test (release ∘ minor!)(vm) == "11.2.0"
  for pv ∈ 1:10;
    @test split((release ∘ patch!)(vm), SEP)[end] == "$(pv)"
  end
  @test (release ∘ major!)(vm) == "12.0.0"

  for pv ∈ 10:-1:0;
    @test (release ∘ rollback)(vm) == "11.2.$(pv)"
  end

  @test (release ∘ rollback)(vm) == "11.1.0"
  @test (release ∘ rollback)(vm) == "11.0.0"
  @test (release ∘ rollback)(vm) == sv

  @test_throws ArgumentError rollback(vm)
end

@testset "combine major, minor, patch and rollback/3 - limit" begin
  sv = "10.2.0"
  vm = VM(sv)

  for pv ∈ 1:99;
    @test split((release ∘ patch!)(vm), SEP)[end] == "$(pv)"
  end

  for pv ∈ 99:-1:99 - N;
    @test (release ∘ rollback)(vm) == string(sv[1:5], "$(pv - 1)")
  end

  @test_throws ArgumentError rollback(vm) # only N previous values memorized!

  @test (release ∘ major!)(vm) == "11.0.0" # prev == 10.2.78
  @test (release ∘ major!)(vm) == "12.0.0"

  @test (release ∘ rollback)(vm) == "11.0.0"
  @test (release ∘ rollback)(vm) == "10.2.78"

  @test_throws ArgumentError rollback(vm) # only N previous values memorized!
end

@testset "release" begin
  sv = "10.2.3"
  vm = VM("10.2.3")

  @test release(vm) == sv
end
