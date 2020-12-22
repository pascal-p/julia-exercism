module YAQ
  ## Yet Another Queue impl.
  import Base: length, isempty,
    first, last, iterate

  export Q

  export length, isempty, isfull,
    enqueue!, dequeue!, reset!,
    iterate

  include("./queue.jl")
end
