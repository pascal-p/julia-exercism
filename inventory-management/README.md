# Inventory Management

## Instructions

In this exercise, you will be managing an inventory system.

The inventory should be organized by the item name and it should keep track of the number of items available.

You will have to handle adding items to an inventory. Each time an item appears in a given list, increase the item's quantity by `1` in the inventory. Then, you will have to handle deleting items from an inventory.

To finish, you will have to implement a function which returns all the key-value pairs in an inventory as a list of `tuples`.

## 1. Create an inventory based on a list

Implement the `create_inventory()` function that creates an "inventory" from a list of items. It should return a `dict` containing each item name paired with their respective quantity.

```julia-repl
create_inventory(["wood", "iron", "iron", "diamond", "diamond"])
Dict{String, UInt}("iron" => UInt(2), "diamond" => UInt(2), "wood" => UInt(1))
```

## 2. Add items from a list to an existing dictionary

Implement the `add_items!()` function that adds a list of items to an inventory:

```julia-repl
>>> add_items!(Dict{String, UInt}("wood" => UInt(4), "iron" => UInt(2)), ["iron", "coal", "wood"])
Dict{String, UInt}("iron" => UInt(3), "coal" => UInt(1), "wood" => UInt(5))
```

## 3. Decrement items from the inventory

Implement the `decrement_items!(<items>)` function that takes a `list` of items. The function should remove one from the available count in the inventory for each time an item appears on the `list`:

```python
>>> decrement_items!(Dict{String, UInt}("coal" => UInt(3), "diamond" => UInt(1), "iron" => UInt(5)), ["diamond", "coal", "iron", "iron"])
Dict{String, UInt}("coal" => UInt(2), "diamond" => UInt(0), "iron" => UInt(3))
```

Item counts in the inventory should not fall below 0. If the number of times an item appears on the list exceeds the count available, the quantity listed for that item should remain at 0 and additional requests for removing counts should be ignored.

```julia-repl
>>> decrement_items(Dict{String, UInt}("coal" => UInt(2), "wood" => UInt(1), "diamond" => UInt(2)), ["coal", "coal", "wood", "wood", "diamond"])
Dict{String, UInt}("coal" => UInt(0), "wood" => UInt(0), "diamond" => UInt(1))
```

## 4. Remove an item entirely from the inventory

Implement the `remove_item!(<inventory>, <item>)` function that removes an item and its count entirely from an inventory:

```julia-repl
>>> remove_item!(Dict{String, UInt}("coal" => UInt(2), "wood" => UInt(1), "diamond" => UInt(2)), "coal")
Dict{String, UInt}("wood" => UInt(1), "diamond" => UInt(2))
```

If the item is not found in the inventory, the function should return the original inventory unchanged.

```julia-repl
>>> remove_item!(Dict{String, UInt}("coal" => UInt(2), "wood" => UInt(1), "diamond" => UInt(2)), "gold")
Dict{String, UInt}("coal" => UInt(2), "wood" => UInt(1), "diamond" => UInt(2))
```

## 5. Return the inventory content

Implement the `list_inventory()` function that takes an inventory and returns a list of `(item, quantity)` tuples. The list should only include the available items (with a quantity greater than zero):

```julia-repl
>>> list_inventory(Dict{String, UInt}("coal" => UInt(7), "wood" => UInt(11), "diamond" => UInt(2), "iron" => UInt(7), "silver" => UInt(0)))
[('coal', UInt(7)), ('diamond', UInt(2)), ('iron', UInt(7)), ('wood', UInt(11))]
```
