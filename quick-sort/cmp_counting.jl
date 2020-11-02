using Test

include("quicksort.jl")


# Programming Problem 5.6: QuickSort

#     Test case #1: This file contains 10 integers, representing a 10-element array. Your program should count 25 comparisons if you always use the first element as the pivot, 31 comparisons if you always use the last element as the pivot, and 21 comparisons if you always use the median-of-3 as the pivot (not counting the comparisons used to compute the pivot).

#     Test case #2: This file contains 100 integers, representing a 100-element array. Your program should count 620 comparisons if you always use the first element as the pivot, 573 comparisons if you always use the last element as the pivot, and 502 comparisons if you always use the median-of-3 as the pivot (not counting the comparisons used to compute the pivot).

# Challenge data set: This file contains all of the integers between 1 and 10,000 (inclusive) in some order, with no integer repeated. The ith row of the file indicates the ith entry of an array. How many comparisons does QuickSort make on this input when the first element is always chosen as the pivot? If the last element is always chosen as the pivot? If the median-of-3 is always chosen as the pivot?

function slurp(ifile) # :: vector of ints
  open(ifile) do f
    readlines(f)
  end |> a -> map(s -> parse(Int, s), a)
end

@testset "qsort 10 num" begin
  x = [2148, 9058, 7742, 3153, 6324, 609, 7628, 5469, 7017, 504]
  sorted_x = [ 504, 609, 2148, 3153, 5469, 6324, 7017, 7628, 7742, 9058]
  nb_cmp = 25

  @test quick_sort!(x, shuffle=false, cmp_count=true) == (sorted_x, nb_cmp)

  x = [2148, 9058, 7742, 3153, 6324, 609, 7628, 5469, 7017, 504]
  @test quick_sort!(x, shuffle=false, cmp_count=true, pivot="last") == (sorted_x, 31)

  x = [2148, 9058, 7742, 3153, 6324, 609, 7628, 5469, 7017, 504]
  @test quick_sort!(x, shuffle=false, cmp_count=true, pivot="median-3") == (sorted_x, 21) # 21
end

@testset "qsort 100 num" begin
  x = slurp("file_100_num.txt")
  sorted_x = slurp("file_100_num_sorted.txt")
  nb_cmp_first = 620
  nb_cmp_last = 573
  nb_cmp_med = 502

  @assert length(x) == 100
  @assert length(sorted_x) == 100

  @test quick_sort!(x, shuffle=false, cmp_count=true) == (sorted_x, nb_cmp_first)

  x = slurp("file_100_num.txt")
  @test quick_sort!(x, shuffle=false, cmp_count=true, pivot="last") == (sorted_x, nb_cmp_last)

  x = slurp("file_100_num.txt")
  @test quick_sort!(x, shuffle=false, cmp_count=true, pivot="median-3") == (sorted_x, nb_cmp_med)
end

@testset "qsort 100 num - random sleection of pivot" begin
  sorted_x = slurp("file_100_num_sorted.txt")

  tot_nb_cmp = 0
  for ix in 1:10
    x = slurp("file_100_num.txt")
    s_act, nb_cmp = quick_sort!(x, shuffle=false, cmp_count=true, pivot="random")
    tot_nb_cmp += nb_cmp

    @test s_act == sorted_x
  end
  tot_nb_cmp = tot_nb_cmp ÷ 10
  println("number of comparisons: $(tot_nb_cmp)") # 640...
end

@testset "qsort 10000 num" begin
  x = slurp("file_10000_num.txt")
  sorted_x = slurp("file_10000_num_sorted.txt")
  nb_cmp_first = 162_085
  nb_cmp_last = 164_123
  nb_cmp_med = 138_382
  exp = 10_000

  @assert length(x) == exp "Expected $(exp) got $(length(x)) !"
  @assert length(sorted_x) == exp

  # 1
  @test quick_sort!(x, shuffle=false, cmp_count=true) == (sorted_x, nb_cmp_first)

  # 2
  x = slurp("file_10000_num.txt")
  @test quick_sort!(x, shuffle=false, cmp_count=true; pivot="last") == (sorted_x, nb_cmp_last)

  # 3
  x = slurp("file_10000_num.txt")
  @test quick_sort!(x, shuffle=false, cmp_count=true; pivot="median-3") == (sorted_x, nb_cmp_med)
end

@testset "qsort 10_000 num - random sleection of pivot" begin
  sorted_x = slurp("file_10000_num_sorted.txt")

  tot_nb_cmp = 0
  for ix in 1:10
    x = slurp("file_10000_num.txt")
    s_act, nb_cmp = quick_sort!(x, shuffle=false, cmp_count=true, pivot="random")
    tot_nb_cmp += nb_cmp

    @test s_act == sorted_x
  end
  tot_nb_cmp = tot_nb_cmp ÷ 10
  println("number of comparisons: $(tot_nb_cmp)") # 153746...
end
