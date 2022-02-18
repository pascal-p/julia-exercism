using Test

include("inventory.jl")


@testset "create_inventory" begin
  @test create_inventory(["wood", "iron", "iron", "diamond", "diamond"]) == Dict{String, UInt}(
    "iron" => UInt(2),
    "diamond" => UInt(2),
    "wood" => UInt(1)
  )
end

@testset "add_items" begin
  @test add_items!(Dict{String, UInt}("wood" => UInt(4), "iron" => UInt(2)), ["iron", "iron"]) == Dict{String, UInt}(
    "iron" => UInt(4),
    "wood" => UInt(4)
  )

  @test add_items!(Dict{String, UInt}("wood" => UInt(4), "iron" => UInt(2)), ["gold"]) == Dict{String, UInt}(
    "gold" => UInt(1),
    "iron" => UInt(2),
    "wood" => UInt(4)
  )

  @test add_items!(
    Dict{String, UInt}("wood" => UInt(4), "iron" => UInt(2), "gold" => UInt(1)),
    ["wood", "gold", "gold"]) == Dict{String, UInt}(
      "gold" => UInt(3),
      "iron" => UInt(2),
      "wood" => UInt(5)
    )

  @test add_items!(Dict{String, UInt}("wood" => UInt(4), "iron" => UInt(2)), ["iron", "gold", "gold"]) == Dict{String, UInt}(
    "gold" => UInt(2),
    "iron" => UInt(3),
    "wood" => UInt(4)
  )
end

@testset "decrement_items" begin
  @test decrement_items!(Dict{String, UInt}(
    "iron" => UInt(3), "diamond" => UInt(4), "gold" =>  UInt(2)
  ), ["iron", "iron", "diamond", "gold", "gold"]) == Dict{String, UInt}("diamond" => UInt(3), "gold" => UInt(0), "iron" => UInt(1))

end

@testset "remove_items" begin
  @test remove_item!(Dict{String, UInt}("iron" => UInt(1), "diamond" => UInt(2), "gold" => UInt(1)),
                     "wood") == Dict{String, UInt}("diamond" => UInt(2), "gold" => UInt(1), "iron" => UInt(1))

  @test remove_item!(Dict{String, UInt}("iron" => UInt(1), "diamond" => UInt(2), "gold" => UInt(1)),
                     "diamond") == Dict{String, UInt}("gold" => UInt(1), "iron" => UInt(1))

end

@testset "list_inventory" begin
  @test list_inventory(Dict{String, UInt}(
    "coal" => UInt(15), "diamond" => UInt(3), "wood" => UInt(7), "silver" => UInt(0)
  )) == [("diamond", UInt(3)), ("coal", UInt(15)), ("wood", UInt(7))]
end
