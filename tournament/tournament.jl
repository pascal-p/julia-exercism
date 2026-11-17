using Printf

const VS = AbstractVector{<:AbstractString}
const THEADER = "Team                           | MP |  W |  D |  L |  P"
const SEP = ";"

struct TeamStats
    m_played::UInt   # MP / Matches Played
    m_won::UInt      # W  / Matches Won
    m_drawn::UInt    # D  / Matches Drawn (Tied)
    m_loss::UInt     # L  /  Matches Lost
    pts::UInt        # P  / Points
end

TeamStats() = TeamStats(0, 0, 0, 0, 0)

function Base.:+(a::TeamStats, b::TeamStats)
    TeamStats(
        a.m_played + b.m_played,
        a.m_won + b.m_won,
        a.m_drawn + b.m_drawn,
        a.m_loss + b.m_loss,
        a.pts + b.pts,
    )
end

const WIN_STATS = TeamStats(1, 1, 0, 0, 3)
const DRAW_STATS = TeamStats(1, 0, 1, 0, 1)
const LOSS_STATS = TeamStats(1, 0, 0, 1, 0)

const OUTCOME_DELTAS = Dict(
    "win" => (WIN_STATS, LOSS_STATS),
    "draw" => (DRAW_STATS, DRAW_STATS),
    "loss" => (LOSS_STATS, WIN_STATS),
)

function tally(results::VS)::VS
    length(results) == 0 && return String[THEADER]

    # now length(results) > 0
    dteams = Dict{String,TeamStats}()

    for entry ∈ results
        lhs_team, rhs_team, sres = split(entry, SEP)
        lhs_delta, rhs_delta = get(OUTCOME_DELTAS, sres) do
            throw(ArgumentError("Invalid outcome: $sres (expected win, draw, or loss)"))
        end

        dteams[lhs_team] = get(dteams, lhs_team, TeamStats()) + lhs_delta
        dteams[rhs_team] = get(dteams, rhs_team, TeamStats()) + rhs_delta
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
