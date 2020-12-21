using Test

push!(LOAD_PATH, "./src")
using YA_EEWD
# using YA_EWD
# using YA_BFSP

g = EWDiGraph{Int, Int}(5)

add_edge(g, 1, 2, 4; positive_weight=false)
add_edge(g, 1, 3, 2; positive_weight=false)
add_edge(g, 2, 4, 4; positive_weight=false)
add_edge(g, 3, 5, 2; positive_weight=false)
add_edge(g, 3, 2, -1; positive_weight=false)
add_edge(g, 5, 4, 2; positive_weight=false)

ng = EEWDiGraph{Int, Int}(g)
# bfsp = BFSP{Int, Int}(gp, src)



##
# push!(LOAD_PATH, "../18-0-ewd/src")
# using YA_EWD

push!(LOAD_PATH, "./src")
using YA_BFSP

g = YA_BFSP.EWDiGraph{Int, Int}(5)

add_edge(g, 1, 2, 4; positive_weight=false)
add_edge(g, 1, 3, 2; positive_weight=false)
add_edge(g, 2, 4, 4; positive_weight=false)
add_edge(g, 3, 5, 2; positive_weight=false)
add_edge(g, 3, 2, -1; positive_weight=false)
add_edge(g, 5, 4, 2; positive_weight=false)

src = 1
bfsp = BFSP{Int, Int}(g, src)
