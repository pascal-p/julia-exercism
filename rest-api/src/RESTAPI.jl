module RESTAPI

import Base: get

export Model
export RestAPI, Path, get, post

include("./Model.jl")
using .Model

include("./rest_api.jl")

end ## module
