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

@testset "major" begin
  sv = "1.2.3"
  vm = VM(sv)
  @test major!(vm) |> string == "2.2.3"

  vm = VM(sv)
  @test (major! ∘ major!)(vm) |> string == "3.2.3"
end

@testset "minor" begin
  sv = "1.2.3"
  vm = VM(sv)
  @test minor!(vm) |> string == "1.3.3"

  vm = VM(sv)
  @test (minor! ∘ minor!)(vm) |> string == "1.4.3"
end

@testset "patch" begin
  sv = "1.2.3"
  vm = VM(sv)
  @test patch!(vm) |> string == "1.2.4"

  vm = VM(sv)
  @test (patch! ∘ patch!)(vm) |> string == "1.2.5"
end


@testset "rollback" begin
  vm = VM("10.2.3")

  @test rollback(vm) |> string == "10.2.2"
  @test (rollback ∘ rollback)(vm) |> string == "10.2.0"
  @test (rollback ∘ rollback)(vm) |> string == "10.0.0"
  @test (rollback ∘ rollback)(vm) |> string == "8.0.0"
  @test (rollback ∘ rollback)(vm) |> string == "6.0.0"
  @test (rollback ∘ rollback)(vm) |> string == "4.0.0"
  @test (rollback ∘ rollback)(vm) |> string == "2.0.0"
  @test (rollback ∘ rollback)(vm) |> string == "0.0.0"

  @test_throws ArgumentError (rollback ∘ rollback)(vm)
end
