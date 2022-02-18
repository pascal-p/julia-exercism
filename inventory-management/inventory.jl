function create_inventory(items::Vector{String})::Dict{String, UInt}
  inventory = Dict{String, UInt}()

  for k ∈ items
    if haskey(inventory, k)
      inventory[k] += 1
    else
      get!(inventory, k, 1)
    end
  end

  inventory
end

function add_items!(inventory::Dict{String, UInt}, items::Vector{String})::Dict{String, UInt}
  for k ∈ items
    if haskey(inventory, k)
      inventory[k] += 1
    else
      get!(inventory, k, 1)
    end
  end

  inventory
end

function decrement_items!(inventory::Dict{String, UInt}, items::Vector{String})::Dict{String, UInt}
  for k ∈ items
    haskey(inventory, k) && inventory[k] > 0 && (inventory[k] -= 1)
  end

  inventory
end

function remove_item!(inventory::Dict{String, UInt}, item::String)::Dict{String, UInt}
  haskey(inventory, item) && (pop!(inventory, item))

  inventory
end

list_inventory(inventory::Dict{String, UInt})::Vector{Tuple{String, UInt}} = [(k, v) for (k, v) ∈ inventory if v > 0]
