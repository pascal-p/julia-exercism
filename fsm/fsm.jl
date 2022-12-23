#
# FSM implementation
#

abstract type State end

const StN = Union{State, Nothing}

# Transitions can either be explicit or implicit;
#    explicit transitions are triggered by an input signal and
#    implicit transitions by the internal state of the system (that is, the current state).
# Implicit transitions thus represent "automatic" or sequenced states that are generally processed between explicit transitions
# (although they can also be used to provide an optional path when no valid transition exists for a given input signal).

macro add_state_fields()
  ## transitions: from this state to others state(s), can be empty
  ## implicit: does this state has an implicit transition to another state
  ## label: a characterization of the state

  return esc(
    :(transitions::Dict{Symbol, DataType};
      implicit::StN;
      label::String)
  )
end

struct Ready <: State
  @add_state_fields()
end

struct Waiting <: State
  @add_state_fields()
end

struct Dispense <: State
  @add_state_fields()
end

struct Refunding <: State
  @add_state_fields()
end

struct Exit <: State
  @add_state_fields()
end

## constructors
Ready() = Ready(
  Dict(:deposit => Waiting, :quit => Exit),
  nothing,
  "Vending machine is ready."
)

Waiting() = Waiting(
  Dict(:select => Dispense, :refund => Refunding),
  nothing,
  "Waiting with funds."
)

Dispense() = Dispense(
  Dict(:remove => Ready),
  nothing,
  "Thank you! Product dispensed."
)

Refunding() = Refunding(
  Dict(),
  Ready(),                 ## implicit transition
  "Please take refund."
)

Exit() = Exit(
  Dict(),
  nothing,
  "Halting."
)

for state ∈ (:Ready, :Waiting, :Dispense, :Refunding, :Exit)
  @eval begin
    genstate($state) = $state()
  end
end

isimplicit(s::State) = s.implicit !== nothing

quitting(_::State) = false
quitting(_::Exit) = true

next_state!(s::State, transition::Symbol) = get(s.transitions, transition, nothing)
next_state!(s::State, transition::String) = s.transitions[transition |> Symbol]


function labelinput(state)
  choices = [
    (s[1], s[2:end]) for s ∈ keys(state.transitions) .|> string
  ]

  prompt = string(state.label, join([" ($(w[1]))$(w[2])" for w ∈ choices], ","), "? ")
  print(prompt)

  while true
    choice = readline()

    if !isempty(choice) && (x = findfirst(s -> s[1] == choice[1], choices)) !== nothing
      return next_state!(state, join(choices[x], ""))
    end

    print(string("redo: ", prompt))
  end
end

function runsim(state::State)
  while true
    if isimplicit(state)
      println(state.label)
      state = state.implicit

    elseif quitting(state)
      println(state.label)
      break

    else
      state = labelinput(state) |> genstate
    end
  end
end

# julia> runsim(Refunding())
# Please take refund.
# Vending machine is ready. (d)eposit, (q)uit? d
# Waiting with funds. (s)elect, (r)efund? s
# Thank you! Product dispensed. (r)emove? r
# Vending machine is ready. (d)eposit, (q)uit? q
# Halting.

# julia> runsim(Ready())
# Vending machine is ready. (d)eposit, (q)uit? d
# Waiting with funds. (s)elect, (r)efund? s
# Thank you! Product dispensed. (r)emove? q
# redo: Thank you! Product dispensed. (r)emove? r
# Vending machine is ready. (d)eposit, (q)uit? q
# Halting.
