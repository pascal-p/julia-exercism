using Test

include("median_maint.jl")


const MOD = 10_000

function sum_hash(meds)
  foldl((s, (k, v)) -> s += k * v, collect(meds); init=0)
end

function incr_median(lim)
  meds = Dict{Int, Int}(k => 2 for k in collect(1:lim ÷ 2)) |>
    h -> collect(h) |>
    h -> sort(h)

  (sum_hash(meds) % MOD, meds)
end

function decr_median(lim)
  hsh = Dict{Int, Int}(k => 2 for k in collect(lim - 1:-1:lim ÷ 2 + 1))
  hsh[lim] = 1
  lim % 2 == 0 && (hsh[lim ÷ 2] = 1)
  meds = collect(hsh) |>
    h -> sort(h)

  (sum_hash(meds) % MOD, meds)
end

@testset "median tests 1..6 / 1" begin
  lim = 6
  e_median, e_medians = incr_median(lim)
  @test median_maint(collect(1:lim); with_medians=true) == (e_median, e_medians)
end

@testset "median tests 1..6 / 2" begin
  exp_medians = sort(collect(Dict{Int, Int}(1 => 1, 2 => 3, 3 => 2)))

  @test median_maint([2, 1, 3, 4, 5, 6]; with_medians=true) == (13, exp_medians)
end

@testset "median tests 5..1" begin
  lim = 5
  e_median, e_medians = decr_median(lim)
  @test median_maint(collect(lim:-1:1); with_medians=true) == (e_median, e_medians)
end

@testset "median tests 1..10" begin
  lim = 10
  e_median, e_medians = incr_median(lim)
  @test median_maint(collect(1:lim); with_medians=true) == (e_median, e_medians)
end

@testset "median tests 10..1" begin
  lim = 10
  e_median, e_medians = decr_median(lim)
  @test median_maint(collect(lim:-1:1); with_medians=true) == (e_median, e_medians)
end

@testset "median tests 1..100" begin
  lim = 100
  e_median, e_medians = incr_median(lim)
  @test median_maint(collect(1:lim); with_medians=true) == (e_median, e_medians)
end

@testset "median tests 1..5000" begin
  lim = 5_000
  e_median, e_medians = incr_median(lim)
  @test median_maint(collect(1:lim); with_medians=true) == (e_median, e_medians)
end

@testset "median tests 1..10_000" begin
  lim = 10_000
  e_median, e_medians = incr_median(lim)

  @test median_maint(collect(1:lim); with_medians=true) == (e_median, e_medians)
  @test median_maint(collect(1:lim); with_medians=false)[1] == e_median
end

@testset "median tests 1..10_000" begin
  lim = 10_000
  e_median, e_medians = decr_median(lim)
  @test median_maint(collect(lim:-1:1); with_medians=true) == (e_median, e_medians)
  @test median_maint(collect(lim:-1:1); with_medians=false)[1] == e_median
end

@testset "median problem11.3 tests" begin
  exp_medians = sort(collect(Dict{Int, Int}(6331 => 1, 2793 => 6, 1640 => 1, 2303 => 2)))
  @test median_maint("testfiles/problem11.3test.txt"; with_medians=true) == (9335, exp_medians)
end

@testset "median problem11.3.txt" begin
  exp_medians = [1640 => 1, 2303 => 2, 2793 => 9, 3480 => 9, 3505 => 2, 3555 => 10, 3611 => 17, 3719 => 6, 3912 => 31, 3932 => 37, 4135 => 19, 4154 => 4, 4164 => 17, 4181 => 15, 4194 => 5, 4200 => 43, 4229 => 51, 4231 => 5, 4232 => 12, 4239 => 76, 4249 => 59, 4256 => 7, 4273 => 21, 4275 => 27, 4277 => 73, 4281 => 28, 4289 => 122, 4292 => 103, 4308 => 52, 4312 => 85, 4315 => 87, 4319 => 60, 4321 => 23, 4329 => 34, 4333 => 40, 4345 => 38, 4348 => 67, 4351 => 45, 4352 => 46, 4356 => 3, 4357 => 25, 4358 => 24, 4360 => 41, 4368 => 58, 4392 => 13, 4403 => 31, 4405 => 50, 4414 => 45, 4417 => 43, 4424 => 45, 4429 => 29, 4437 => 32, 4438 => 6, 4442 => 31, 4445 => 11, 4447 => 13, 4448 => 47, 4450 => 58, 4456 => 48, 4462 => 36, 4465 => 28, 4466 => 45, 4468 => 30, 4469 => 5, 4470 => 25, 4472 => 2, 4473 => 17, 4479 => 26, 4480 => 43, 4481 => 94, 4482 => 54, 4483 => 107, 4484 => 129, 4485 => 31, 4486 => 87, 4489 => 17, 4492 => 50, 4497 => 9, 4501 => 33, 4502 => 3, 4503 => 23, 4504 => 16, 4513 => 32, 4514 => 52, 4521 => 40, 4523 => 6, 4524 => 23, 4526 => 22, 4527 => 29, 4528 => 22, 4531 => 14, 4533 => 19, 4534 => 2, 4536 => 4, 4537 => 2, 4538 => 2, 4540 => 2, 4541 => 8, 4544 => 20, 4557 => 34, 4561 => 20, 4564 => 14, 4571 => 12, 4572 => 4, 4573 => 2, 4578 => 2, 4582 => 3, 4583 => 3, 4588 => 11, 4591 => 16, 4594 => 4, 4596 => 9, 4598 => 25, 4599 => 24, 4602 => 19, 4605 => 29, 4608 => 18, 4614 => 36, 4615 => 59, 4618 => 32, 4619 => 4, 4621 => 32, 4625 => 42, 4630 => 63, 4631 => 75, 4633 => 63, 4636 => 34, 4637 => 21, 4639 => 13, 4643 => 5, 4644 => 7, 4647 => 20, 4648 => 62, 4651 => 58, 4652 => 53, 4653 => 81, 4654 => 59, 4655 => 20, 4658 => 2, 4663 => 11, 4668 => 16, 4669 => 22, 4672 => 18, 4674 => 36, 4675 => 36, 4676 => 25, 4678 => 5, 4682 => 9, 4688 => 14, 4689 => 23, 4691 => 34, 4696 => 27, 4698 => 16, 4699 => 6, 4703 => 2, 4705 => 4, 4706 => 10, 4707 => 11, 4708 => 8, 4709 => 23, 4710 => 24, 4711 => 18, 4712 => 25, 4714 => 47, 4716 => 80, 4717 => 60, 4722 => 33, 4723 => 32, 4724 => 19, 4725 => 23, 4726 => 13, 4727 => 29, 4729 => 25, 4730 => 6, 4731 => 7, 4732 => 12, 4733 => 32, 4734 => 30, 4737 => 32, 4740 => 11, 4741 => 2, 4747 => 4, 4748 => 25, 4749 => 35, 4750 => 49, 4751 => 23, 4753 => 6, 4754 => 4, 4760 => 13, 4761 => 5, 4763 => 2, 4764 => 10, 4765 => 8, 4768 => 2, 4771 => 2, 4774 => 2, 4775 => 5, 4776 => 3, 4780 => 12, 4783 => 18, 4784 => 6, 4785 => 6, 4786 => 14, 4787 => 25, 4790 => 3, 4791 => 9, 4792 => 18, 4793 => 18, 4795 => 21, 4796 => 18, 4798 => 7, 4799 => 5, 4800 => 2, 4801 => 3, 4803 => 11, 4804 => 13, 4806 => 13, 4807 => 43, 4809 => 68, 4810 => 52, 4811 => 28, 4813 => 30, 4814 => 28, 4816 => 16, 4818 => 5, 4819 => 7, 4821 => 7, 4822 => 11, 4824 => 18, 4825 => 29, 4826 => 45, 4827 => 65, 4828 => 74, 4829 => 29, 4830 => 11, 4831 => 5, 4833 => 8, 4837 => 4, 4839 => 12, 4840 => 36, 4841 => 57, 4843 => 63, 4847 => 31, 4848 => 17, 4849 => 32, 4851 => 60, 4852 => 57, 4854 => 55, 4856 => 47, 4857 => 52, 4859 => 62, 4860 => 78, 4861 => 60, 4862 => 28, 4863 => 13, 4864 => 23, 4865 => 23, 4867 => 35, 4868 => 23, 4869 => 6, 4870 => 13, 4872 => 10, 4873 => 4, 4874 => 7, 4877 => 3, 4883 => 7, 4884 => 18, 4885 => 34, 4886 => 24, 4887 => 18, 4889 => 26, 4891 => 31, 4892 => 11, 4893 => 11, 4895 => 6, 4896 => 3, 4898 => 17, 4899 => 28, 4900 => 41, 4901 => 20, 4903 => 10, 4904 => 26, 4905 => 20, 4906 => 10, 4907 => 15, 4908 => 30, 4909 => 37, 4910 => 31, 4911 => 22, 4913 => 14, 4914 => 8, 4915 => 24, 4916 => 13, 4918 => 4, 4920 => 12, 4921 => 14, 4922 => 7, 4923 => 17, 4925 => 9, 4926 => 10, 4928 => 10, 4929 => 17, 4930 => 10, 4931 => 15, 4932 => 7, 4934 => 3, 4935 => 3, 4937 => 5, 4938 => 4, 4942 => 8, 4943 => 4, 4944 => 7, 4945 => 6, 4946 => 5, 4947 => 7, 4949 => 10, 4950 => 7, 4951 => 7, 4952 => 8, 4953 => 16, 4954 => 15, 4955 => 19, 4956 => 16, 4957 => 31, 4958 => 41, 4959 => 39, 4960 => 62, 4961 => 105, 4962 => 144, 4964 => 100, 4965 => 64, 4966 => 53, 4968 => 48, 4969 => 34, 4970 => 9, 4971 => 16, 4972 => 39, 4973 => 79, 4974 => 36, 4975 => 3, 4976 => 2, 4977 => 2, 4979 => 2, 4982 => 7, 4983 => 7, 4984 => 2, 4985 => 2, 4987 => 11, 4988 => 12, 4989 => 4, 4990 => 6, 4991 => 14, 4994 => 51, 4995 => 56, 4996 => 48, 4997 => 2, 4998 => 49, 4999 => 76, 5000 => 29, 5001 => 104, 5002 => 65, 5003 => 109, 5004 => 76, 5005 => 131, 5006 => 80, 5007 => 55, 5008 => 24, 5009 => 22, 5010 => 35, 5011 => 9, 5147 => 1, 6331 => 1]

  @test median_maint("testfiles/problem11.3.txt"; with_medians=true) == (1213, exp_medians)
end
