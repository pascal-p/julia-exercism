using Test

include("exchange.jl")

@testset "exchange_money" begin
  input_data = [(100000, 0.84), (700000, 10.1), (127.5, 1.2)]
  output_data = [119047.62, 69306.93, 106.25]

  for (input, expected) ∈ zip(input_data, output_data)
    @test exchange_money(input...) == Decimal(expected)
  end
end

@testset "get_change" begin
  input_data = [(463000, 5000), (1250, 120), (15000, 1380), (127.5, 120)]
  output_data = [458000, 1130, 13620, 7.5]

   for (input, expected) ∈ zip(input_data, output_data)
    @test get_change(input...) == Decimal(expected)
  end
end

@testset "get_value_of_bills" begin
  input_data = [(10000, 128), (50, 360), (200, 200), (5, 128)]
  output_data = [1280000, 18000, 40000, 640]

  for (input, expected) ∈ zip(input_data, output_data)
    @test get_value_of_bills(input...) == expected
  end
end

@testset "exchangeable_value" begin
   inputs = [
     (100000, 10.61, 10, 1),
     (1500, 0.84, 25, 40),
     (470000, 1050, 30, 10000000000),
     (470000, 0.00000009, 30, 700),
     (425.33, 0.0009, 30, 700),
     (127.25, 1.20, 10, 20),
     (127.25, 1.20, 10, 5),
   ]
  output_data = [8568, 1400, 0, 4017094016600, 363300, 80, 95]

  for (input, expected) ∈ zip(inputs, output_data)
    @test exchangeable_value(input...) == expected
  end
end

@testset "non_exchangeable_value" begin
   inputs = [
     (100000, 10.61, 10, 1),
     (1500, 0.84, 25, 40),
     # (470000, 1050, 30, 10000000000),
     # (470000, 0.00000009, 30, 700),
     (425.33, 0.0009, 30, 700),
     (12000, 0.0096, 10, 50),
     (127.25, 1.20, 10, 20),
     (127.25, 1.20, 10, 5),
   ]
  output_data = [ 0,
                  28,
                  229,
                  13,
                  16, 1
                  ]

  for (input, expected) ∈ zip(inputs, output_data)
    @test non_exchangeable_value(input...) == expected
  end
end
