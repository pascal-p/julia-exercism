module YAHT
  import Base: show, isempty, get, size

  export HTable, size, isempty, show,
         get, add!, remove!

  include("../../11-sllist/src/sllist.jl")
  include("htable.jl")
end
