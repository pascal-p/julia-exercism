# canonical data version: 2.4.0 (auto-generated)

using Dates, Test

include("clock.jl")

@testset "Create a new clock with an initial time / hour. min" begin
  # on the hour
  @test Clock(8, 0) == Clock(8, 0)

  # past the hour
  @test Clock(11, 9) == Clock(11, 9)

  # midnight is zero hours
  @test Clock(24, 0) == Clock(0, 0)

  # hour rolls over
  @test Clock(25, 0) == Clock(1, 0)

  # hour rolls over continuously
  @test Clock(100, 0) == Clock(4, 0)

  # sixty minutes is next hour
  @test Clock(1, 60) == Clock(2, 0)
  @test Clock(1, 60, 60) == Clock(2, 1)  ## Addition

  # minutes roll over
  @test Clock(0, 160) == Clock(2, 40)

  # minutes roll over continuously
  @test Clock(0, 1723) == Clock(4, 43)

  # hour and minutes roll over
  @test Clock(25, 160) == Clock(3, 40)

  # hour and minutes roll over continuously
  @test Clock(201, 3001) == Clock(11, 1)

  # hour and minutes roll over to exactly midnight
  @test Clock(72, 8640) == Clock(0, 0)

  # negative hour
  @test Clock(-1, 15) == Clock(23, 15)

  # negative hour rolls over
  @test Clock(-25, 0) == Clock(23, 0)

  # negative hour rolls over continuously
  @test Clock(-91, 0) == Clock(5, 0)

  # negative minutes
  @test Clock(1, -40) == Clock(0, 20)

  # negative minutes roll over
  @test Clock(1, -160) == Clock(22, 20)

  # negative minutes roll over continuously
  @test Clock(1, -4820) == Clock(16, 40)

  # negative sixty minutes is previous hour
  @test Clock(2, -60) == Clock(1, 0)

  @test Clock(3, -180) == Clock(0, 0)  ## Addition

  # negative hour and minutes both roll over
  @test Clock(-25, -160) == Clock(20, 20)

  # negative hour and minutes both roll over continuously
  @test Clock(-121, -5810) == Clock(22, 10)
end

@testset "Create a new clock with an initial time / hour. min, sec" begin
  @test Clock(8, 0) == Clock(8, 0, 0)

  @test Clock(11, 9, 10) == Clock(11, 9, 10)

  @test Clock(11, 9, 61) == Clock(11, 10, 1)

  @test Clock(24, 70, 90) == Clock(1, 11, 30)

  @test Clock(0, 0, 3600) == Clock(1, 0, 0)

  @test Clock(0, 0, 3661) == Clock(1, 1, 1)

  @test Clock(0, 120, 3661) == Clock(3, 1, 1)

  @test Clock(1, 1, -40) == Clock(1, 0, 20)

  @test Clock(1, 1, -60) == Clock(1, 0, 0)

  @test Clock(1, 1, -180) == Clock(0, 58, 0)

  @test Clock(1, 0, -180) == Clock(0, 57, 0)

  @test Clock(1, 0, -3600) == Clock(0, 0, 0)

  @test Clock(3, -60, -7200) == Clock(0, 0, 0)

  @test Clock(3, -60, 7200) == Clock(4, 0, 0)

  @test Clock(3, 60, -7200) == Clock(2, 0, 0)

  @test Clock(-121, -5810, -600) == Clock(22, 0, 0)

  @test Clock(-121, -5810, 930) == Clock(22, 25, 30)
end

@testset "Add minutes" begin
  # add minutes
  @test Clock(10, 0) + Dates.Minute(3) == Clock(10, 3)
  @test Dates.Minute(3) + Clock(10, 0) == Clock(10, 3)

  # add no minutes
  @test Clock(6, 41) + Dates.Minute(0) == Clock(6, 41)
  @test Dates.Minute(0) + Clock(6, 41) == Clock(6, 41)

  # add to next hour
  @test Clock(0, 45) + Dates.Minute(40) == Clock(1, 25)
  @test Dates.Minute(40) + Clock(0, 45) == Clock(1, 25)

  # add more than one hour
  @test Clock(10, 0) + Dates.Minute(61) == Clock(11, 1)
  @test Dates.Minute(61) + Clock(10, 0) == Clock(11, 1)

  # add more than two hours with carry
  @test Clock(0, 45) + Dates.Minute(160) == Clock(3, 25)
  @test Dates.Minute(160) + Clock(0, 45) == Clock(3, 25)

  # add across midnight
  @test Clock(23, 59) + Dates.Minute(2) == Clock(0, 1)
  @test Dates.Minute(2)  + Clock(23, 59) == Clock(0, 1)

  # add more than one day (1500 min = 25 hrs)
  @test Clock(5, 32) + Dates.Minute(1500) == Clock(6, 32)
  @test Dates.Minute(1500) + Clock(5, 32) == Clock(6, 32)

  # add more than two days
  @test Clock(1, 1) + Dates.Minute(3500) == Clock(11, 21)
  @test Dates.Minute(3500) + Clock(1, 1) == Clock(11, 21)
end

@testset "Add minutes, seconds" begin
  ## 6 variations
  @test Clock(10, 0, 0) + Dates.Minute(3) + Dates.Second(10) == Clock(10, 3, 10)
  @test Clock(10, 0, 0) + Dates.Second(10) + Dates.Minute(3) == Clock(10, 3, 10)
  @test Dates.Minute(3) + Clock(10, 0, 0) + Dates.Second(10) == Clock(10, 3, 10)
  @test Dates.Minute(3) + Dates.Second(10) + Clock(10, 0, 0) == Clock(10, 3, 10)
  @test Dates.Second(10) + Dates.Minute(3) + Clock(10, 0, 0) == Clock(10, 3, 10)
  @test Dates.Second(10) + Clock(10, 0, 0) + Dates.Minute(3) == Clock(10, 3, 10)

  @test Clock(6, 41, 0) + Dates.Second(30) == Clock(6, 41, 30)
  @test Dates.Second(30) + Clock(6, 41, 0) == Clock(6, 41, 30)

  @test Clock(1, 1, 30) + Dates.Second(3600) == Clock(2, 1, 30)
  @test Dates.Second(3600) + Clock(1, 1, 30) == Clock(2, 1, 30)

  @test Clock(1, 1, 10) + Dates.Second(7386) == Clock(3, 4, 16)
  @test Dates.Second(7386) + Clock(1, 1, 10) == Clock(3, 4, 16)

  @test Clock(1, 30, 6) + Dates.Second(86400) == Clock(1, 30, 6)
  @test Dates.Second(86400) + Clock(1, 30, 6) == Clock(1, 30, 6)
end

@testset "Subtract minutes" begin
  # subtract minutes
  @test Clock(10, 3) - Dates.Minute(3) == Clock(10, 0)

  # subtract to previous hour
  @test Clock(10, 3) - Dates.Minute(30) == Clock(9, 33)

  # subtract more than an hour
  @test Clock(10, 3) - Dates.Minute(70) == Clock(8, 53)

  # subtract across midnight
  @test Clock(0, 3) - Dates.Minute(4) == Clock(23, 59)

  # subtract more than two hours
  @test Clock(0, 0) - Dates.Minute(160) == Clock(21, 20)

  # subtract more than two hours with borrow
  @test Clock(6, 15) - Dates.Minute(160) == Clock(3, 35)

  # subtract more than one day (1500 min = 25 hrs)
  @test Clock(5, 32) - Dates.Minute(1500) == Clock(4, 32)

  # subtract more than two days
  @test Clock(2, 20) - Dates.Minute(3000) == Clock(0, 20)

  # - 1 day
  @test Clock(2, 20) - Dates.Minute(1440) == Clock(2, 20)

  #
  @test Clock(14, 45) - Dates.Minute(165) == Clock(12, 0)
  for m in 1:59
    @test Clock(14, 45) - Dates.Minute(165 + m) == Clock(11, 60 - m)
  end
end

@testset "Subtract seconds, minutes and seconds" begin
  ## Using left associativity

  @test Clock(10, 3, 30) - Dates.Minute(3) - Dates.Second(30) == Clock(10, 0, 0)

  @test Clock(10, 3, 30) - Dates.Minute(30) - Dates.Second(27) == Clock(9, 33, 3)

  @test Clock(10, 3, 30) - Dates.Minute(30) - Dates.Second(90) == Clock(9, 32, 0)

  @test Clock(0, 3, 55) - Dates.Minute(3) - Dates.Second(110) == Clock(23, 59, 5)

  #
  @test Clock(14, 45, 55) - Dates.Minute(165) - Dates.Second(0) == Clock(12, 0, 55)
  @test Clock(14, 45, 55) - Dates.Minute(165) - Dates.Second(55) == Clock(12, 0, 0)

  ## minus 24h (in sec == 86400)
  @test Clock(2, 20, 1) - Dates.Second(86400) == Clock(2, 20, 1)

  ## minus 23h (in sec == 82800)
  @test Clock(2, 20, 1) - Dates.Second(82800) == Clock(3, 20, 1)

  ## minus 25h (in sec == 90000)
  @test Clock(2, 20, 1) - Dates.Second(90000) == Clock(1, 20, 1)

  for s in 2:61
    ## minus 25h00m02s (in sec == 90002)
    @test Clock(2, 20, 1) - Dates.Second(90000 + s) == Clock(1, 19, 61 - s)
  end

  ## - 2 day
  @test Clock(2, 20, 1) - Dates.Minute(1440) - Dates.Second(86400) == Clock(2, 20, 1)

  ## lelft associativity
  @test Clock(2, 20, 1) - Dates.Second(86400) - Dates.Minute(1440) == Clock(2, 20, 1)
end

@testset "Compare two clocks for equality" begin
  # clocks with same time
  @test Clock(15, 37) == Clock(15, 37)

  # clocks a minute apart
  @test Clock(15, 36) != Clock(15, 37)

  # clocks an hour apart
  @test Clock(14, 37) != Clock(15, 37)

  # clocks with hour overflow
  @test Clock(10, 37) == Clock(34, 37)

  # clocks with hour overflow by several days
  @test Clock(3, 11) == Clock(99, 11)

  # clocks with negative hour
  @test Clock(22, 40) == Clock(-2, 40)

  # clocks with negative hour that wraps
  @test Clock(17, 3) == Clock(-31, 3)

  # clocks with negative hour that wraps multiple times
  @test Clock(13, 49) == Clock(-83, 49)

  # clocks with minute overflow
  @test Clock(0, 1) == Clock(0, 1441)

  # clocks with minute overflow by several days
  @test Clock(2, 2) == Clock(2, 4322)

  # clocks with negative minute
  @test Clock(2, 40) == Clock(3, -20)

  # clocks with negative minute that wraps
  @test Clock(4, 10) == Clock(5, -1490)

  # clocks with negative minute that wraps multiple times
  @test Clock(6, 15) == Clock(6, -4305)

  # clocks with negative hours and minutes
  @test Clock(7, 32) == Clock(-12, -268)

  # clocks with negative hours and minutes that wrap
  @test Clock(18, 7) == Clock(-54, -11513)

  # full clock and zeroed clock
  @test Clock(24, 0) == Clock(0, 0)
end

@testset "displaying clocks" begin
  @test sprint(show, Clock(8, 0)) == "\"08:00\""
  @test sprint(show, Clock(11, 9)) == "\"11:09\""
  @test sprint(show, Clock(24, 0)) == "\"00:00\""
  @test sprint(show, Clock(25, 0)) == "\"01:00\""
  @test sprint(show, Clock(100, 0)) == "\"04:00\""
  @test sprint(show, Clock(1, 60)) == "\"02:00\""
  @test sprint(show, Clock(0, 160)) == "\"02:40\""
  @test sprint(show, Clock(0, 1723)) == "\"04:43\""
  @test sprint(show, Clock(25, 160)) == "\"03:40\""
  @test sprint(show, Clock(201, 3001)) == "\"11:01\""
  @test sprint(show, Clock(72, 8640)) == "\"00:00\""
  @test sprint(show, Clock(-1, 15)) == "\"23:15\""
  @test sprint(show, Clock(-25, 0)) == "\"23:00\""
  @test sprint(show, Clock(-91, 0)) == "\"05:00\""
  @test sprint(show, Clock(1, -40)) == "\"00:20\""
  @test sprint(show, Clock(1, -160)) == "\"22:20\""
  @test sprint(show, Clock(1, -4820)) == "\"16:40\""
  @test sprint(show, Clock(2, -60)) == "\"01:00\""
  @test sprint(show, Clock(-25, -160)) == "\"20:20\""
  @test sprint(show, Clock(-121, -5810)) == "\"22:10\""
end
