using Test

include("./space_age.jl")

@testset "age on earth" begin
  @test space_age_on_earth(1000000000) ≡ 31.69
end
@testset "age on mercury" begin
  @test space_age_on_mercury(2134835688) ≡ 280.88
end

@testset "age on venus" begin
  @test space_age_on_venus(189839836) ≡ 9.78
end

@testset "age on mars" begin
  @test space_age_on_mars(2129871239) ≡ 35.88
end

@testset "age on jupiter" begin
  @test space_age_on_jupiter(901876382) ≡ 2.41
end

@testset "age on saturn" begin
  @test space_age_on_saturn(2000000000) ≡ 2.15
end

@testset "age on uranus" begin
  @test space_age_on_uranus(1210123456) ≡ 0.46
end

@testset "age on neptune" begin
  @test space_age_on_neptune(1821023456) ≡ 0.35
end
