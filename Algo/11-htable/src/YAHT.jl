module YAHT

  import Base: show, isempty, get, size

  export HTable, size, isempty, show,
         get, add!, remove!

  include("htable.jl")
end
