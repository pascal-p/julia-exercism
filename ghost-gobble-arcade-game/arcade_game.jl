"""
    eat_ghost(power_pellet_active::Bool, touching_ghost::Bool)::Bool

# Examples
```julia-repl
julia> eat_ghost(false, true)
false
```
"""
eat_ghost(power_pellet_active::Bool, touching_ghost::Bool)::Bool = power_pellet_active && touching_ghost

"""
   score(touching_power_pellet::Bool, touching_dot::Bool)::Bool

# Examples
```
julia> score(true, true)
true
```
"""
score(touching_power_pellet::Bool, touching_dot::Bool)::Bool = touching_power_pellet || touching_dot

"""
   lose(power_pellet_active::Bool, touching_ghost::Bool)::Bool

# Examples
```julia-repl
julia> lose(false, true)
true
```
"""
lose(power_pellet_active::Bool, touching_ghost::Bool)::Bool = !power_pellet_active && touching_ghost

"""
    win(has_eaten_all_dots::Bool, power_pellet_active::Bool, touching_ghost::Bool)::Bool

# Examples
```julia-repl
julia> win(false, true, false)
false
```
"""
function win(has_eaten_all_dots::Bool, power_pellet_active::Bool, touching_ghost::Bool)::Bool
  has_eaten_all_dots && !lose(power_pellet_active, touching_ghost)
end
