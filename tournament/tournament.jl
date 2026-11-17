using Printf

const VS = AbstractVector{<:AbstractString}
const THEADER = "Team                           | MP |  W |  D |  L |  P"
const SEP = ";"

@enum Outcome loss=0 draw=1 win=3

mutable struct TeamStats
    m_played::UInt   # MP / Matches Played
    m_won::UInt      # W  / Matches Won
    m_drawn::UInt    # D  / Matches Drawn (Tied)
    m_loss::UInt     # L  /  Matches Lost
    pts::UInt        # P  / Points

    # function Team(name::AbstractString, res::Outcome)
    #     m_played = 1
    #     m_won = res == win::Outcome ? 1 : 0
    #     m_drawn = res == draw::Outcome ? 1 : 0
    #     m_loss = res == loss::Outcome ? 1 : 0
    #     #
    #     pts = 3 * m_won + 1 * m_drawn
    #     new(m_played, m_won, m_drawn, m_loss, pts)
    # end

    TeamStats() = new(0, 0, 0, 0, 0)
end

function update!(ts::TeamStats, outcome::Outcome)
    ts.m_played += 1
    ts.m_won += outcome == win
    ts.m_drawn += outcome == draw
    ts.m_loss += outcome == loss
    ts.pts += UInt(outcome)
end

# function Base.show(io::IO, t::Team)
#   print(io, ...)
# end

# function Base.isless(t₁::Team, t₂::Team)::Bool
#     t₁.pts > t₂.pts || (t₁.pts == t₂.pts && t₁.name < t₂.name)
# end

function tally(results::VS)::VS
    length(results) == 0 && return String[THEADER]

    # now length(results) > 0
    dteams = Dict{String,TeamStats}()

    for entry ∈ results
        (lhs_team, rhs_team, sres) = split(entry, SEP)
        res = outcome_convert(sres)

        for t ∈ (lhs_team, rhs_team)
            update!(get!(TeamStats, dteams, t), res)
            res = flip_outcome(res)
        end
    end

    ## All teams updated => display
    teams = collect(dteams)                                   # ≝ Vector{Pair{String,TeamStats}})
    sort!(teams; by = ((name, ts),) -> (-Int(ts.pts), name))  # NOTE: Int(ts.pts) so negating a UInt doesn't wrap around!

    table = [THEADER]
    for (tname, ts) ∈ teams
        push!(
            table,
            @sprintf(
                "%-31s|%3d |%3d |%3d |%3d |%3d",
                tname,
                ts.m_played,
                ts.m_won,
                ts.m_drawn,
                ts.m_loss,
                ts.pts
            ),
        )
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

function flip_outcome(res::Outcome)::Outcome
    if res == win::Outcome
        return loss::Outcome
    elseif res == loss::Outcome
        return win::Outcome
    end

    return draw::Outcome
end
