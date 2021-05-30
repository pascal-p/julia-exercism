using Test

include("allergies.jl")

@testset "eggs allergy" begin
  @testset "not allergic to anything" begin
    allergies = Allergies(0)
    @test !allergic_to(allergies, "eggs")
  end

  @testset "allergic only to eggs" begin
    allergies = Allergies(1)
    @test allergic_to(allergies, "eggs")
  end

  @testset "allergic to eggs and something else" begin
    allergies = Allergies(3)
    @test allergic_to(allergies, "eggs")
  end

  @testset "allergic to something, but not eggs" begin
    allergies = Allergies(2.0)             # yes this float works...
    @test !allergic_to(allergies, "eggs")
  end

  @testset "allergic to everything" begin
    allergies = Allergies(255)
    @test allergic_to(allergies, "eggs")
  end
end

@testset "peanuts allergy" begin
  @testset "not allergic to anything" begin
    allergies = Allergies(0)
    @test !allergic_to(allergies, :peanuts)
  end

  @testset "allergic only to peanuts" begin
    allergies = Allergies(2)
    @test allergic_to(allergies, :peanuts)
  end

  @testset "allergic to peanuts and something else" begin
    allergies = Allergies(7)
    @test allergic_to(allergies, :peanuts)
  end

  @testset "allergic to something, but not peanuts" begin
    allergies = Allergies(5)
    @test !allergic_to(allergies, :peanuts)
  end

  @testset "allergic to everything" begin
    allergies = Allergies(255)
    @test allergic_to(allergies, :peanuts)
  end
end

@testset "shellfish allergy" begin
  @testset "not allergic to anything" begin
    allergies = Allergies(0.0)
    @test !allergic_to(allergies, :shellfish)
  end

  @testset "allergic only to shellfish" begin
    allergies = Allergies(4)
    @test allergic_to(allergies, :shellfish)
  end

  @testset "allergic to shellfish and something else" begin
    allergies = Allergies(14.0)
    @test allergic_to(allergies, :shellfish)
  end

  @testset "allergic to something, but not shellfish" begin
    allergies = Allergies(10)
    @test !allergic_to(allergies, :shellfish)
  end

  @testset "allergic to everything" begin
    allergies = Allergies(255)
    @test allergic_to(allergies, :shellfish)
  end
end

@testset "strawberries allergy" begin
  @testset "not allergic to anything" begin
    allergies = Allergies(0.0)
    @test !allergic_to(allergies, :strawberries)
  end

  @testset "allergic only to strawberries" begin
    allergies = Allergies(8)
    @test allergic_to(allergies, :strawberries)
  end

  @testset "allergic to strawberries and something else" begin
    allergies = Allergies(28)
    @test allergic_to(allergies, :strawberries)
  end

  @testset "allergic to something, but not strawberries" begin
    allergies = Allergies(20)
    @test !allergic_to(allergies, :strawberries)
  end

  @testset "allergic to everything" begin
    allergies = Allergies(255)
    @test allergic_to(allergies, :strawberries)
  end
end

@testset "tomatoes allergy" begin
  @testset "not allergic to anything" begin
    allergies = Allergies(0.0)
    @test !allergic_to(allergies, :tomatoes)
  end

  @testset "allergic only to tomatoes" begin
    allergies = Allergies(16)
    @test allergic_to(allergies, :tomatoes)
  end

  @testset "allergic to tomatoes and something else" begin
    allergies = Allergies(56)
    @test allergic_to(allergies, :tomatoes)
  end

  @testset "allergic to something, but not tomatoes" begin
    allergies = Allergies(40)
    @test !allergic_to(allergies, :tomatoes)
  end

  @testset "allergic to everything" begin
    allergies = Allergies(255)
    @test allergic_to(allergies, :tomatoes)
  end

end

@testset "chocolate allergy" begin
  @testset "not allergic to anything" begin
    allergies = Allergies(0.0)
    @test !allergic_to(allergies, :chocolate)
  end

  @testset "allergic only to chocolate" begin
    allergies = Allergies(32)
    @test allergic_to(allergies, :chocolate)
  end

  @testset "allergic to chocolate and something else" begin
    allergies = Allergies(112)
    @test allergic_to(allergies, :chocolate)
  end

  @testset "allergic to something, but not chocolate" begin
    allergies = Allergies(80)
    @test !allergic_to(allergies, :chocolate)
  end

  @testset "allergic to everything" begin
    allergies = Allergies(255)
    @test allergic_to(allergies, :chocolate)
  end

end

@testset "pollen allergy" begin
  @testset "not allergic to anything" begin
    allergies = Allergies(0.0)
    @test !allergic_to(allergies, :pollen)
  end

  @testset "allergic only to pollen" begin
    allergies = Allergies(64)
    @test allergic_to(allergies, :pollen)
  end

  @testset "allergic to pollen and something else" begin
    allergies = Allergies(224)
    @test allergic_to(allergies, :pollen)
  end

  @testset "allergic to something, but not pollen" begin
    allergies = Allergies(160)
    @test !allergic_to(allergies, :pollen)
  end

  @testset "allergic to everything" begin
    allergies = Allergies(255)
    @test allergic_to(allergies, :pollen)
  end
end

@testset "cats allergy" begin
  @testset "not allergic to anything" begin
    allergies = Allergies(0.0)
    @test !allergic_to(allergies, :cats)
  end

  @testset "allergic only to cats" begin
    allergies = Allergies(128)
    @test allergic_to(allergies, :cats)
  end

  @testset "allergic to cats and something else" begin
    allergies = Allergies(192)
    @test allergic_to(allergies, :cats)
  end

  @testset "allergic to something, but not cats" begin
    allergies = Allergies(64)
    @test !allergic_to(allergies, :cats)
  end

  @testset "allergic to everything" begin
    allergies = Allergies(255)
    @test allergic_to(allergies, :cats)
  end
end


@testset "list when" begin
  @testset "no allergies" begin
    allergies = Allergies(0)
    @test list(allergies) == []
  end

  @testset "just eggs" begin
    allergies = Allergies(1)
    @test list(allergies) == [:eggs]
  end

  @testset "just peanuts" begin
    allergies = Allergies(2)
    @test list(allergies) == [:peanuts]
  end

  @testset "just strawberries" begin
    allergies = Allergies(8)
    @test list(allergies) == [:strawberries]
  end

  @testset "eggs and peanuts" begin
    allergies = Allergies(3)
    @test list(allergies) == [:eggs, :peanuts]
  end

  @testset "more than eggs but not peanuts" begin
    allergies = Allergies(5)
    @test list(allergies) == [:eggs, :shellfish]
  end

  @testset "lots of stuff" begin
    allergies = Allergies(248)
    @test list(allergies) == [
        :strawberries,
        :tomatoes,
        :chocolate,
        :pollen,
        :cats,
    ]
  end

  @testset "everything" begin
    allergies = Allergies(255)
    @test list(allergies) == [
        :eggs,
        :peanuts,
        :shellfish,
        :strawberries,
        :tomatoes,
        :chocolate,
        :pollen,
        :cats,
    ]
  end

  @testset "no allergen score parts" begin
    allergies = Allergies(509)
    @test list(allergies) == [
        :eggs,
        :shellfish,
        :strawberries,
        :tomatoes,
        :chocolate,
        :pollen,
        :cats,
    ]
  end
end


@testset "Exceptions" begin
  @test_throws ArgumentError Allergies(:foo)

  @test_throws ArgumentError Allergies("bar")

  @test_throws MethodError Allergies(π)
end
