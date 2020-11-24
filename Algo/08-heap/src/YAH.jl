module YAH
  # Yet Another Heap ADT
  # import Base: isempty, size

  export Heap, MinHeap, MaxHeap

  export size, isempty, peek
  export insert!, delete!, heapify!
  export extract_min!, extract_max!

  include("./heap.jl")
end
