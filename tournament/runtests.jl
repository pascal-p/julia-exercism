using Test

include("./tournament.jl")

@testset "just the header if no input" begin
  results = String[]
  table = ["Team                           | MP |  W |  D |  L |  P"]
  @test tally(results) == table
end

@testset "test a win is 3 points a loss is 0 points" begin
  results = ["Allegoric Alaskans;Blithering Badgers;win"]
  table = [
           "Team                           | MP |  W |  D |  L |  P",
           "Allegoric Alaskans             |  1 |  1 |  0 |  0 |  3",
           "Blithering Badgers             |  1 |  0 |  0 |  1 |  0",
        ]
  @test tally(results) == table
end

@testset "a win can also be expressed as a loss" begin
  results = ["Blithering Badgers;Allegoric Alaskans;loss"]
  table = [
           "Team                           | MP |  W |  D |  L |  P",
           "Allegoric Alaskans             |  1 |  1 |  0 |  0 |  3",
           "Blithering Badgers             |  1 |  0 |  0 |  1 |  0",
        ]
  @test tally(results) == table
end


@testset "a different team can win" begin
  results = ["Blithering Badgers;Allegoric Alaskans;win"]
  table = [
           "Team                           | MP |  W |  D |  L |  P",
           "Blithering Badgers             |  1 |  1 |  0 |  0 |  3",
           "Allegoric Alaskans             |  1 |  0 |  0 |  1 |  0",
           ]
   @test tally(results) == table
end

@testset "a draw is one point each" begin
  results = ["Allegoric Alaskans;Blithering Badgers;draw"]
  table = [
           "Team                           | MP |  W |  D |  L |  P",
           "Allegoric Alaskans             |  1 |  0 |  1 |  0 |  1",
           "Blithering Badgers             |  1 |  0 |  1 |  0 |  1",
           ]
  @test tally(results) == table
end

@testset "there can be more than one match" begin
  results = [
             "Allegoric Alaskans;Blithering Badgers;win",
             "Allegoric Alaskans;Blithering Badgers;win",
             ]
  table = [
           "Team                           | MP |  W |  D |  L |  P",
           "Allegoric Alaskans             |  2 |  2 |  0 |  0 |  6",
           "Blithering Badgers             |  2 |  0 |  0 |  2 |  0",
           ]
  @test tally(results) == table
end

@testset "there can be more than one winner" begin
  results = [
             "Allegoric Alaskans;Blithering Badgers;loss",
             "Allegoric Alaskans;Blithering Badgers;win",
        ]
  table = [
           "Team                           | MP |  W |  D |  L |  P",
           "Allegoric Alaskans             |  2 |  1 |  0 |  1 |  3",
           "Blithering Badgers             |  2 |  1 |  0 |  1 |  3",
           ]

  @test tally(results) == table
end

@testset "there can be more than two teams" begin
  results = [
             "Allegoric Alaskans;Blithering Badgers;win",
             "Blithering Badgers;Courageous Californians;win",
            "Courageous Californians;Allegoric Alaskans;loss",
             ]
  table = [
           "Team                           | MP |  W |  D |  L |  P",
           "Allegoric Alaskans             |  2 |  2 |  0 |  0 |  6",
           "Blithering Badgers             |  2 |  1 |  0 |  1 |  3",
            "Courageous Californians        |  2 |  0 |  0 |  2 |  0",
           ]
   @test tally(results) == table
end

@testset "typical input" begin
  results = [
             "Allegoric Alaskans;Blithering Badgers;win",
             "Devastating Donkeys;Courageous Californians;draw",
             "Devastating Donkeys;Allegoric Alaskans;win",
             "Courageous Californians;Blithering Badgers;loss",
             "Blithering Badgers;Devastating Donkeys;loss",
             "Allegoric Alaskans;Courageous Californians;win",
             ]
  table = [
           "Team                           | MP |  W |  D |  L |  P",
           "Devastating Donkeys            |  3 |  2 |  1 |  0 |  7",
           "Allegoric Alaskans             |  3 |  2 |  0 |  1 |  6",
           "Blithering Badgers             |  3 |  1 |  0 |  2 |  3",
           "Courageous Californians        |  3 |  0 |  1 |  2 |  1",
           ]
  @test tally(results) == table
end

@testset "incomplete competition not all pairs have played" begin
  results = [
             "Allegoric Alaskans;Blithering Badgers;loss",
             "Devastating Donkeys;Allegoric Alaskans;loss",
             "Courageous Californians;Blithering Badgers;draw",
             "Allegoric Alaskans;Courageous Californians;win",
             ]
  table = [
           "Team                           | MP |  W |  D |  L |  P",
           "Allegoric Alaskans             |  3 |  2 |  0 |  1 |  6",
           "Blithering Badgers             |  2 |  1 |  1 |  0 |  4",
           "Courageous Californians        |  2 |  0 |  1 |  1 |  1",
           "Devastating Donkeys            |  1 |  0 |  0 |  1 |  0",
           ]

  @test tally(results) == table
end

@testset "ties broken alphabetically" begin
  results = [
             "Courageous Californians;Devastating Donkeys;win",
             "Allegoric Alaskans;Blithering Badgers;win",
             "Devastating Donkeys;Allegoric Alaskans;loss",
             "Courageous Californians;Blithering Badgers;win",
             "Blithering Badgers;Devastating Donkeys;draw",
             "Allegoric Alaskans;Courageous Californians;draw",
             ]
  table = [
           "Team                           | MP |  W |  D |  L |  P",
           "Allegoric Alaskans             |  3 |  2 |  1 |  0 |  7",
           "Courageous Californians        |  3 |  2 |  1 |  0 |  7",
           "Blithering Badgers             |  3 |  0 |  1 |  2 |  1",
           "Devastating Donkeys            |  3 |  0 |  1 |  2 |  1",
           ]
  @test tally(results) == table
end
