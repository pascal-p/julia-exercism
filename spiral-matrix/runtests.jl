using Test

include("./spiral_matrix.jl")


@testset "empty spiral" begin
   m = Matrix{Int}(undef, 0, 0)
  @test spiral_matrix(0) == m
end

@testset "trivial spiral" begin
  m = Matrix{Int}(undef, 1, 1); m[1, 1] = 1
  @test spiral_matrix(1) == m
end

@testset "spiral of size 2" begin
  @test spiral_matrix(2) == [1 2; 4 3]
end

@testset "spiral of size 3" begin
  @test spiral_matrix(3) == [1 2 3; 8 9 4; 7 6 5]
end

@testset "spiral of size 4" begin
  @test spiral_matrix(4) == [ 1 2 3 4;
                              12 13 14 5;
                              11 16 15 6;
                              10 9 8 7 ]
end

@testset "spiral of size 5" begin
  @test spiral_matrix(5) == [1 2 3 4 5;
                             16 17 18 19 6;
                             15 24 25 20 7;
                             14 23 22 21 8;
                             13 12 11 10 9]
end

@testset "spiral of size 6" begin
  @test spiral_matrix(6) == [1 2 3 4 5 6;
                             20 21 22 23 24 7;
                             19 32 33 34 25 8;
                             18 31 36 35 26 9;
                             17 30 29 28 27 10;
                             16 15 14 13 12 11]

end

@testset "spiral of size 10" begin
  @test spiral_matrix(10) == [1 2 3 4 5 6 7 8 9 10;
                              36 37 38 39 40 41 42 43 44 11;
                              35 64 65 66 67 68 69 70 45 12;
                              34 63 84 85 86 87 88 71 46 13;
                              33 62 83 96 97 98 89 72 47 14;
                              32 61 82 95 100 99 90 73 48 15;
                              31 60 81 94 93 92 91 74 49 16;
                              30 59 80 79 78 77 76 75 50 17;
                              29 58 57 56 55 54 53 52 51 18;
                              28 27 26 25 24 23 22 21 20 19]
end
