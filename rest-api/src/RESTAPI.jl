module RESTAPI

import Base: get

export Model
export RestAPI, get, post

include("./Model.jl")
using .Model

include("./rest_api.jl")

end ## module
