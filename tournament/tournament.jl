using Printf

const VS = Vector{String}
const THEADER = "Team                           | MP |  W |  D |  L |  P"
const SEP = ";"

@enum Outcome loss=0 draw=1 win=3

mutable struct Team
  name::String
  m_played::Int   # MP / Matches Played
  m_won::Int      # W  / Matches Won
  m_drawn::Int    # D  / Matches Drawn (Tied)
  m_loss::Int     # L  /  Matches Lost
  pts::Int        # P  / Points

  function Team(name::AbstractString, res::Outcome)
    m_played = 1
    m_won   = res == win::Outcome  ? 1 : 0
    m_drawn = res == draw::Outcome ? 1 : 0
    m_loss  = res == loss::Outcome ? 1 : 0
    #
    pts = 3 * m_won + 1 * m_drawn
    new(string(name), m_played, m_won, m_drawn, m_loss, pts)
  end
end

function update!(t::Team, res::Outcome)
  t.m_played += 1

  if res == win::Outcome
    t.pts += 3
    t.m_won += 1

  elseif res == draw::Outcome
    t.pts += 1
    t.m_drawn += 1

  else
    t.m_loss += 1    ## loss
  end

end

# function Base.show(io::IO, t::Team)
#   print(io, ...)
# end

function Base.isless(t₁::Team, t₂::Team)::Bool
  t₁.pts > t₂.pts ||
    (t₁.pts == t₂.pts && t₁.name < t₂.name)
end

function tally(results::VS)::VS
  length(results) == 0 && return String[THEADER]

  # length(results) > 0
  dteams = Dict{String, Team}()

  for entry ∈ results
    (lt, rt, sres) = split(entry, SEP)
    res = outcome_convert(sres)

    for t ∈ (lt, rt)
      t == rt && (res = outcome_reverse(res))

      if get(dteams, t, nothing) != nothing
        update!(dteams[t], res)  ## team update
      else
        dteams[t] = Team(t, res) ## team create
      end
    end
  end

  ## All teams updated => display
  teams = Vector{Team}([vt for (_, vt) ∈ dteams])
  sort!(teams, lt=Base.isless, rev=false)

  table = [ THEADER ]
  for t ∈ teams
    push!(table,
          @sprintf("%-31s|%3d |%3d |%3d |%3d |%3d", t.name, t.m_played, t.m_won, t.m_drawn, t.m_loss, t.pts))
  end

  table
end

##
## Internal helpers
##

function outcome_convert(res::AbstractString)::Outcome
  ## validation
  Symbol(res) ∉ map(s -> Symbol(s), instances(Outcome)) &&
    throw(ArgumentError("Only: $(instances(Outcome))"))

  ## conversion
  return filter(s -> Symbol(res) == Symbol(s), instances(Outcome))[1]
end

function outcome_reverse(res::Outcome)::Outcome
  if res == win::Outcome
    return loss::Outcome
  elseif res == loss::Outcome
    return win::Outcome
  end

  return draw::Outcome
end
