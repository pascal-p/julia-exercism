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

#
# All these tests are not going to performed well with simple BST
# as the order of insertion maatters => here we get the worse case with the
# equivalent of linked list!
#

# @testset "median tests 1..100" begin
#   lim = 100
#   e_median, e_medians = incr_median(lim)
#   @test median_maint(collect(1:lim); with_medians=true) == (e_median, e_medians)
# end

# @testset "median tests 1..5000" begin
#   lim = 5_000
#   e_median, e_medians = incr_median(lim)
#   @test median_maint(collect(1:lim); with_medians=true) == (e_median, e_medians)
# end

# @testset "median tests 1..10_000" begin
#   lim = 10_000
#   e_median, e_medians = incr_median(lim)

#   @test median_maint(collect(1:lim); with_medians=true) == (e_median, e_medians)
#   @test median_maint(collect(1:lim); with_medians=false)[1] == e_median
# end

# @testset "median tests 1..10_000" begin
#   lim = 10_000
#   e_median, e_medians = decr_median(lim)
#   @test median_maint(collect(lim:-1:1); with_medians=true) == (e_median, e_medians)
#   @test median_maint(collect(lim:-1:1); with_medians=false)[1] == e_median
# end


@testset "shuffled 1..100 integers" begin
  inp = [11, 7, 47, 68, 85, 46, 98, 6, 54, 20, 71, 39, 66, 4, 58, 26, 56, 30, 37, 19, 53, 18, 14, 73, 67, 89, 52, 13, 38, 17, 62, 44, 91, 8, 61, 9, 2, 95, 5, 69, 72, 90, 27, 10, 65, 57, 32, 93, 23, 15, 29, 92, 49, 84, 59, 100, 51, 79, 34, 48, 97, 31, 70, 83, 36, 74, 16, 25, 43, 1, 78, 33, 55, 86, 75, 87, 80, 99, 12, 21, 42, 81, 24, 76, 64, 22, 77, 28, 88, 45, 60, 50, 3, 35, 94, 63, 96, 40, 41, 82]
  e_median, e_medians = (4553, [7 => 1, 11 => 3, 39 => 5, 44 => 11, 46 => 26, 47 => 12, 48 => 7, 49 => 20, 50 => 7, 51 => 8])

  @test median_maint(inp; with_medians=true) == (e_median, e_medians)
end

@testset "shuffled 1..5_000 integers" begin
  inp = [ 3130, 3534, 3558, 2351, 3724, 2729, 4264, 2098, 1468, 1688, 3210, 1344, 4440, 39, 1399, 912, 471, 1082, 1128, 4976, 2270, 622, 3522, 4568, 124, 2220, 1790, 1804, 581, 2327, 1478, 2544, 2262, 4461, 336, 4329, 209, 1964, 3038, 3933, 3195, 2375, 4570, 2043, 2010, 739, 1402, 3624, 1296, 1940, 269, 3480, 4234, 3813, 860, 1633, 3868, 2868, 1519, 3604, 3218, 4161, 3729, 2274, 3467, 3116, 2713, 2368, 89, 2903, 840, 3190, 4, 3619, 699, 535, 743, 4992, 642, 793, 149, 2815, 3791, 4107, 1745, 2991, 3258, 4970, 396, 1129, 1076, 4304, 4325, 1567, 722, 1018, 2610, 2766, 215, 2983, 570, 4713, 1497, 4952, 3761, 1839, 946, 2621, 2498, 1979, 280, 4247, 3835, 4612, 4737, 1876, 1968, 30, 1528, 445, 3119, 3061, 271, 3963, 1597, 4437, 2294, 2624, 3853, 693, 3254, 1524, 997, 1797, 1205, 3566, 3657, 696, 4378, 2972, 1896, 4140, 2142, 4467, 1100, 4580, 3859, 318, 2832, 4689, 1050, 3801, 97, 4060, 4650, 3900, 2110, 551, 3784, 4915, 4555, 377, 383, 1639, 882, 1231, 3434, 4742, 2108, 2131, 1412, 1097, 2293, 3053, 326, 2869, 4413, 4523, 706, 2976, 4245, 3358, 875, 1034, 3307, 2456, 3319, 3355, 2266, 128, 831, 3781, 4665, 2439, 1833, 3356, 1323, 940, 504, 2165, 1431, 4193, 4693, 2180, 1834, 3156, 2742, 2759, 358, 923, 1759, 1153, 2914, 2591, 4780, 347, 689, 3944, 1274, 695, 1529, 1358, 878, 2777, 1805, 917, 3482, 2347, 2138, 2997, 3143, 3844, 239, 3749, 1789, 2818, 1703, 1913, 4168, 1148, 4851, 3708, 91, 2414, 1042, 4581, 2258, 2714, 2852, 36, 813, 1366, 832, 2069, 4930, 597, 3455, 2447, 4725, 2239, 1250, 213, 171, 4225, 2217, 3324, 4905, 3873, 3070, 1899, 4901, 4741, 4125, 4402, 178, 3100, 3068, 4138, 2603, 3185, 1746, 4102, 3654, 1314, 869, 1887, 4529, 4585, 241, 3473, 1461, 2996, 4317, 2164, 618, 2760, 3955, 3505, 2503, 2802, 588, 1749, 1932, 3799, 903, 4122, 3275, 4697, 245, 2096, 2465, 4550, 4923, 3865, 6, 2119, 4944, 4347, 1051, 1069, 851, 941, 107, 2527, 4095, 2459, 3233, 3182, 86, 4290, 2039, 2071, 2290, 1253, 1223, 3240, 3921, 2160, 2947, 3739, 4036, 3406, 1143, 4392, 4070, 2643, 2551, 1068, 789, 714, 3958, 4462, 234, 4860, 3501, 133, 2112, 4762, 2083, 3915, 1768, 3125, 1144, 4321, 427, 815, 4343, 1792, 4311, 2901, 3610, 3715, 1474, 3227, 4289, 4396, 340, 3494, 4040, 2710, 3686, 1719, 2812, 402, 2683, 792, 52, 1396, 1696, 4093, 2699, 3952, 1224, 2111, 54, 1388, 1857, 4307, 1285, 2372, 2727, 2052, 3184, 4403, 1931, 3607, 3385, 508, 757, 4053, 2161, 3454, 246, 3598, 2343, 2379, 795, 2186, 2748, 4813, 87, 3191, 4098, 4327, 1290, 3920, 2097, 1784, 2810, 2954, 292, 846, 3318, 28, 1228, 387, 747, 451, 4667, 2303, 1590, 4721, 4023, 3302, 611, 1642, 3118, 2365, 1867, 4050, 3005, 4898, 1378, 712, 1322, 4471, 3665, 1663, 3912, 137, 853, 3575, 1608, 3211, 1433, 1992, 2486, 2332, 3249, 1514, 3716, 170, 4394, 3273, 1227, 4559, 681, 4097, 3907, 4449, 4675, 300, 2382, 4120, 2504, 406, 2523, 4717, 4388, 1102, 3357, 4543, 45, 2122, 4389, 1023, 44, 2872, 2105, 2269, 3320, 3567, 4227, 4065, 785, 494, 896, 1861, 139, 848, 4419, 4092, 392, 72, 3257, 572, 2862, 594, 4236, 3284, 4587, 3044, 4337, 3523, 1907, 4048, 1081, 4884, 4508, 3710, 2337, 814, 3893, 4051, 3632, 2147, 777, 2577, 1442, 1304, 4949, 4067, 655, 744, 1677, 2730, 2817, 4359, 1676, 2509, 498, 1806, 3060, 1447, 3379, 3449, 1272, 907, 2792, 2257, 1767, 3892, 4772, 3343, 113, 1511, 982, 3932, 2289, 2860, 3740, 122, 4747, 866, 751, 180, 1847, 1521, 4864, 3238, 4566, 2261, 4318, 3582, 2608, 3998, 3579, 626, 1779, 4723, 2665, 2229, 4652, 3017, 1389, 4966, 3850, 4310, 1329, 4567, 4208, 2080, 2304, 2341, 4475, 1303, 3219, 1549, 260, 3974, 705, 963, 775, 2399, 4971, 4961, 3423, 612, 1014, 2345, 1828, 1327, 2740, 1685, 1654, 1489, 1204, 4106, 1563, 1087, 2387, 1699, 3154, 341, 4872, 530, 2965, 2134, 2736, 3538, 2575, 812, 3491, 3132, 3923, 3281, 1386, 2502, 1198, 1487, 2185, 3775, 1390, 3655, 3803, 3349, 766, 3220, 2009, 1247, 43, 1864, 3836, 4986, 3237, 544, 4881, 3236, 3726, 82, 2145, 1880, 4716, 4216, 3556, 253, 4611, 3367, 3721, 2443, 2680, 2695, 1898, 4685, 4890, 2429, 4028, 129, 2202, 2668, 197, 1505, 2667, 3440, 3013, 1235, 219, 1546, 3674, 3388, 3525, 1180, 3484, 1477, 4769, 3251, 3247, 507, 77, 1675, 2167, 2645, 1652, 2140, 3975, 4887, 4624, 546, 455, 2973, 399, 1647, 3146, 1000, 4078, 4867, 4176, 983, 1981, 3826, 4222, 4939, 4993, 3152, 1229, 4929, 2969, 2272, 4130, 1765, 1483, 1425, 1440, 422, 3093, 3374, 2931, 2432, 3965, 1578, 4478, 3157, 3825, 434, 1302, 3950, 3255, 2959, 2703, 1008, 4283, 3627, 1761, 1188, 3229, 3828, 4908, 1466, 4578, 3562, 2121, 3145, 1156, 181, 1331, 1772, 995, 3180, 3588, 1809, 942, 187, 3757, 1971, 3621, 3105, 2094, 3435, 678, 967, 1796, 4973, 3217, 2049, 407, 4880, 3918, 958, 2932, 734, 3340, 1850, 2858, 41, 4178, 979, 3573, 628, 2127, 1065, 4644, 3594, 1605, 3369, 532, 4607, 384, 2254, 1720, 683, 4300, 4528, 3667, 1641, 2287, 3551, 1942, 3344, 2050, 2697, 1758, 2132, 4338, 75, 587, 442, 629, 2561, 3269, 4874, 1181, 2472, 2153, 4802, 4369, 1819, 2569, 2292, 175, 1239, 715, 222, 1172, 3798, 2813, 4942, 3135, 791, 1925, 2656, 2520, 2796, 2990, 3902, 4910, 4291, 2824, 2092, 1960, 1802, 1712, 1085, 3177, 1638, 46, 287, 1056, 4712, 4382, 2909, 1033, 541, 4358, 1592, 1843, 1785, 2413, 186, 1332, 1754, 4418, 4521, 1090, 4349, 589, 4752, 34, 1769, 136, 3896, 2391, 143, 1494, 4975, 3378, 1160, 2878, 2745, 1157, 2926, 1010, 834, 3242, 2583, 4632, 585, 2336, 3985, 3364, 2320, 2403, 1420, 1308, 4593, 3890, 4825, 4999, 3919, 1740, 3280, 1243, 2089, 2084, 4514, 2559, 3266, 2837, 4039, 3546, 1460, 1560, 910, 1079, 1369, 2179, 4948, 579, 3879, 2582, 2875, 1508, 1507, 900, 3506, 1627, 474, 4735, 2616, 3732, 1518, 349, 3576, 2664, 4206, 1002, 2911, 4699, 4595, 2925, 4192, 1914, 2704, 1342, 916, 2574, 135, 1423, 955, 4927, 2516, 2647, 559, 1261, 2929, 3045, 870, 953, 3736, 3552, 4182, 3076, 4997, 3213, 1132, 3383, 4132, 1361, 1777, 2025, 4457, 823, 2321, 4368, 1684, 483, 132, 3756, 2318, 1854, 165, 1566, 2870, 4015, 668, 1781, 3633, 3642, 1411, 4121, 778, 2971, 3232, 4856, 1190, 1135, 4663, 2993, 4646, 2942, 1159, 3065, 3120, 4019, 1116, 3403, 2405, 3518, 2513, 2300, 1368, 3121, 574, 565, 2538, 4546, 2612, 4490, 265, 1952, 809, 2821, 1886, 4308, 4745, 3684, 27, 3168, 2585, 1852, 841, 883, 2317, 2093, 314, 971, 3549, 2957, 2176, 4750, 3941, 3981, 2606, 1988, 67, 2774, 2968, 3138, 2445, 4554, 1284, 2794, 4618, 4240, 4866, 4063, 2952, 4303, 2619, 3827, 3380, 4014, 3544, 2021, 4151, 4767, 4260, 4469, 148, 4281, 822, 1353, 435, 3752, 1391, 564, 4160, 368, 3478, 2689, 4822, 3717, 723, 3542, 4562, 3150, 3559, 3704, 1564, 3823, 2476, 19, 4974, 4165, 4688, 420, 4072, 4371, 3111, 3158, 4545, 3336, 993, 190, 725, 1954, 1561, 1350, 3485, 3661, 2933, 1462, 2085, 3067, 1679, 501, 3650, 2018, 1038, 2335, 937, 1278, 3085, 1273, 4695, 1289, 2316, 3051, 818, 800, 4773, 950, 4484, 806, 3080, 610, 708, 1661, 4517, 3611, 3615, 3267, 2291, 2761, 566, 2537, 1283, 632, 3371, 1354, 2642, 4994, 2920, 4621, 2221, 2989, 639, 1016, 3988, 4087, 194, 2579, 2378, 1727, 1164, 2899, 4561, 4022, 3243, 4224, 1872, 4549, 4477, 1673, 1961, 1632, 418, 4421, 3126, 1019, 4510, 1409, 1170, 1105, 1611, 1463, 1374, 4604, 635, 37, 1579, 3495, 3909, 691, 1455, 2366, 1775, 1392, 2313, 1165, 1199, 864, 4373, 153, 100, 2857, 638, 1738, 159, 2711, 4431, 4598, 4287, 1106, 3043, 3196, 1813, 1464, 3797, 674, 1662, 3151, 487, 4639, 1471, 2769, 3581, 3855, 18, 4486, 1057, 3730, 1651, 4519, 4556, 3837, 4211, 1454, 2521, 1667, 2772, 637, 949, 816, 3321, 4252, 3821, 1213, 3408, 3207, 4730, 4351, 2042, 3375, 3444, 857, 4904, 1908, 2876, 3528, 2234, 4958, 1194, 2158, 2394, 4447, 2453, 101, 4385, 2864, 850, 2887, 3989, 3241, 537, 465, 1306, 1782, 1735, 151, 2250, 928, 4967, 68, 1281, 4427, 4213, 1363, 1753, 1334, 2198, 9, 1877, 3817, 261, 411, 728, 2951, 3292, 2073, 1826, 3990, 2490, 4231, 3973, 3488, 192, 944, 3297, 4653, 3635, 4579, 4253, 514, 4984, 1186, 3925, 3811, 1959, 3911, 3922, 3672, 2981, 4670, 1882, 759, 4174, 4821, 3054, 4582, 1177, 3199, 741, 2501, 29, 4414, 334, 3415, 393, 4452, 1902, 3359, 1179, 1, 1114, 106, 1708, 2597, 1823, 4170, 4012, 2409, 989, 3953, 154, 4899, 3583, 1413, 555, 1335, 2048, 877, 96, 669, 1095, 3812, 3725, 2286, 3547, 3405, 478, 3502, 3676, 2620, 1607, 2526, 3533, 755, 760, 1365, 315, 2919, 1901, 1121, 4293, 4800, 2741, 1481, 1094, 662, 1305, 1214, 3511, 2773, 4515, 4705, 1221, 3956, 1794, 1729, 3887, 1904, 977, 3178, 591, 2805, 3347, 2998, 4171, 408, 3436, 4643, 3072, 3035, 3155, 4547, 4728, 528, 1470, 1240, 4803, 595, 2450, 376, 2953, 1271, 4409, 1715, 413, 1115, 1520, 3457, 4002, 1840, 2922, 4331, 4783, 640, 521, 3600, 3315, 2481, 4941, 3937, 2064, 3946, 2168, 2023, 4522, 998, 821, 145, 3587, 1962, 561, 4807, 3539, 4651, 810, 4020, 3354, 1635, 4354, 4355, 1812, 4212, 3109, 1219, 1911, 4136, 2425, 4075, 1596, 4383, 4407, 1540, 3456, 302, 1793, 4035, 3438, 4991, 4609, 3197, 1929, 4902, 2027, 1315, 817, 4964, 4498, 1744, 3101, 2460, 2655, 1716, 3327, 59, 2024, 2548, 1439, 4629, 484, 1945, 1356, 2231, 4465, 704, 3390, 2723, 645, 3057, 1764, 3814, 3042, 4024, 1208, 716, 2488, 3452, 4761, 3856, 4913, 4668, 60, 282, 688, 2861, 1891, 2002, 3134, 2902, 2524, 4935, 1660, 4258, 1757, 1426, 299, 1734, 4008, 1211, 4594, 2109, 4134, 4844, 3819, 1718, 4714, 4605, 3286, 2363, 1626, 2484, 4903, 571, 2522, 1377, 3847, 2854, 3110, 378, 2395, 4428, 3479, 4530, 1943, 2377, 1047, 2938, 4144, 960, 3509, 3291, 3287, 3680, 3938, 1408, 2694, 432, 1723, 2348, 1108, 2787, 648, 247, 1060, 776, 2102, 214, 1210, 1822, 2344, 2638, 2383, 49, 423, 331, 4433, 4482, 3206, 3702, 417, 4719, 1917, 2617, 2000, 2863, 1525, 2091, 1993, 3972, 3967, 1288, 2966, 2566, 4784, 3662, 14, 590, 2912, 313, 930, 1874, 4199, 2706, 2560, 4815, 4215, 1343, 1938, 847, 4280, 1263, 2255, 1537, 2169, 4842, 2307, 3226, 3557, 4796, 2114, 805, 3094, 515, 2078, 1381, 1920, 4152, 4474, 1162, 4292, 4571, 3927, 4873, 1312, 2851, 4739, 446, 3849, 3451, 4841, 619, 2056, 4831, 2853, 3924, 4309, 4187, 1541, 2146, 1906, 4868, 391, 2797, 2814, 3079, 4444, 354, 3832, 2904, 236, 21, 2505, 4625, 238, 1889, 1503, 3959, 1543, 4246, 2075, 710, 3204, 4016, 1029, 1613, 4278, 788, 4862, 3577, 4871, 3673, 240, 4251, 3001, 2707, 1286, 4615, 4538, 4232, 2936, 3417, 886, 3012, 3295, 3095, 4032, 2687, 3796, 2602, 200, 4931, 871, 481, 2511, 2442, 3613, 3465, 1055, 3571, 3392, 1527, 235, 1986, 4259, 3064, 4664, 968, 4520, 4937, 2099, 2367, 945, 752, 38, 195, 2533, 1301, 970, 1118, 1404, 4429, 2309, 2669, 1013, 4495, 794, 4702, 193, 2771, 4496, 1137, 972, 202, 3794, 2086, 425, 1939, 2357, 1453, 1397, 3223, 1801, 1126, 4485, 4334, 4673, 3393, 2360, 3603, 1251, 4827, 2458, 3541, 1875, 4965, 1982, 2916, 4753, 1183, 317, 2014, 3020, 3737, 1452, 819, 4420, 3860, 4219, 4202, 1933, 4153, 2284, 3268, 2063, 598, 3728, 1482, 3486, 3081, 1267, 3895, 4372, 1573, 116, 94, 3361, 1429, 4203, 3137, 943, 902, 2312, 3133, 1556, 2799, 1075, 889, 4047, 199, 584, 53, 3584, 2930, 4956, 332, 3934, 4038, 2342, 4708, 2898, 263, 2793, 1851, 4459, 1043, 3608, 3878, 3548, 1600, 440, 169, 3059, 2055, 3384, 4645, 690, 2653, 2325, 2190, 3171, 1472, 1728, 4954, 2573, 3096, 711, 31, 1922, 2135, 2364, 3471, 1448, 1795, 65, 4375, 2090, 90, 1530, 1256, 4940, 1339, 4009, 3874, 3889, 1700, 364, 1393, 4921, 852, 1978, 4982, 1269, 453, 2546, 401, 1972, 3774, 1337, 1995, 1624, 4086, 3779, 804, 1842, 558, 1730, 2825, 3903, 2033, 1178, 2789, 962, 4494, 3899, 3115, 4883, 3000, 2636, 2020, 2517, 2572, 4710, 2319, 2629, 2433, 3442, 3279, 3653, 2678, 1436, 1206, 4239, 4790, 2223, 2238, 2068, 2003, 3871, 2144, 2349, 2589, 1631, 1146, 1367, 1326, 3777, 2191, 160, 1526, 3419, 2051, 1015, 2725, 291, 4173, 3983, 4184, 4870, 4563, 658, 4853, 1821, 2937, 3545, 4415, 2162, 227, 885, 2705, 3296, 3968, 892, 4678, 3656, 3245, 1798, 2987, 3804, 310, 3381, 2418, 1048, 2519, 283, 2397, 3722, 1395, 1991, 3312, 2390, 4426, 2037, 1707, 1294, 627, 1762, 2675, 3148, 1609, 1295, 2935, 576, 3807, 749, 4828, 685, 2775, 3016, 3387, 130, 3212, 1184, 4744, 3188, 4401, 3751, 3078, 905, 212, 4962, 3160, 3310, 4374, 3066, 3816, 3675, 2525, 4847, 3166, 4010, 2510, 1237, 4330, 1737, 2556, 3314, 2170, 386, 57, 2495, 3274, 2946, 718, 1817, 4535, 874, 2755, 1458, 593, 2423, 204, 4256, 796, 2428, 3514, 3964, 4288, 826, 1364, 3140, 4766, 398, 3500, 251, 2137, 4736, 2402, 3462, 3172, 3645, 3660, 1721, 272, 4306, 1868, 1200, 3322, 3372, 1287, 3469, 1558, 1380, 2204, 3039, 2879, 3561, 4031, 1966, 1552, 2843, 3678, 4524, 3994, 2580, 103, 4489, 2975, 3669, 3031, 1838, 1680, 996, 1196, 3691, 296, 102, 3597, 441, 4988, 361, 4649, 4799, 1379, 3748, 177, 4301, 692, 624, 2867, 4998, 3926, 2732, 1967, 431, 881, 339, 2275, 1217, 1028, 477, 1476, 1829, 3689, 4698, 2172, 4271, 2059, 3426, 4830, 1209, 110, 4005, 2859, 4657, 3490, 3808, 4017, 1499, 3589, 620, 1944, 226, 4073, 3910, 1349, 2053, 335, 1534, 2739, 1260, 4541, 4743, 3328, 4068, 2883, 2750, 4634, 2751, 4751, 1672, 750, 375, 1628, 3373, 3750, 1007, 1553, 2753, 1246, 3833, 3753, 257, 824, 3943, 4316, 479, 827, 4631, 444, 4088, 2752, 1577, 3262, 2148, 3809, 208, 909, 1357, 839, 3139, 3845, 4083, 4623, 10, 2159, 2568, 475, 4118, 1438, 687, 641, 4162, 162, 779, 3563, 2493, 2215, 4430, 4229, 372, 3421, 2958, 4846, 4267, 1709, 4774, 184, 1125, 1218, 1202, 1669, 2849, 548, 4574, 1512, 1072, 201, 872, 20, 3113, 3205, 1340, 3681, 438, 4422, 3353, 3341, 4399, 536, 631, 2209, 4977, 3741, 4951, 4501, 4834, 1743, 661, 3830, 473, 410, 2, 1036, 4733, 4995, 4054, 830, 1910, 828, 2660, 1504, 673, 4423, 4963, 4412, 1725, 4045, 2700, 2350, 762, 4633, 3939, 3376, 3961, 3246, 12, 4608, 3348, 4626, 2449, 3957, 2361, 988, 2475, 2113, 2149, 1428, 1416, 1037, 351, 2141, 3969, 4738, 111, 210, 748, 2780, 2543, 646, 1449, 173, 2173, 2491, 3278, 1572, 198, 3412, 2963, 385, 2469, 3046, 1690, 4079, 2770, 2446, 1594, 4996, 2893, 3884, 2576, 1862, 2535, 1930, 2889, 3875, 2731, 4706, 4056, 355, 3834, 2243, 3311, 4829, 4882, 1927, 3194, 3004, 1410, 2006, 2756, 672, 2945, 307, 2118, 1372, 1811, 994, 3693, 2970, 1977, 3649, 1091, 4589, 2067, 4129, 1866, 2915, 2803, 2746, 2373, 4149, 1432, 2005, 3332, 3755, 4323, 4381, 4115, 4826, 3870, 947, 2310, 1666, 3304, 4945, 4746, 1405, 4328, 3075, 607, 161, 35, 2822, 2557, 4476, 3682, 924, 1515, 2362, 2249, 58, 859, 3298, 4114, 2125, 1089, 1580, 2578, 1569, 346, 1955, 4850, 1835, 4145, 1107, 3883, 1498, 1084, 4641, 3841, 3617, 4711, 4557, 459, 1268, 578, 1052, 4731, 2030, 1625, 3021, 991, 362, 4169, 4516, 3037, 224, 1176, 2765, 653, 436, 999, 412, 510, 4299, 2754, 1736, 4011, 232, 4052, 773, 3685, 1837, 3253, 1686, 1858, 1860, 248, 3787, 152, 2718, 1299, 4364, 1717, 4175, 2865, 405, 3668, 1593, 4455, 981, 225, 306, 4089, 2441, 4740, 3625, 1827, 1150, 2369, 2842, 1957, 3805, 207, 3008, 2962, 659, 2420, 2529, 1731, 244, 1111, 1346, 1571, 4210, 3009, 2844, 2895, 4133, 2791, 2298, 4669, 1292, 880, 802, 3536, 328, 495, 1755, 2593, 66, 255, 2174, 1586, 1127, 374, 3601, 395, 2558, 205, 959, 365, 1003, 3235, 5000, 3931, 23, 2897, 3499, 4600, 25, 2992, 2724, 469, 3136, 3930, 237, 4156, 2743, 1333, 1963, 4472, 1001, 337, 1039, 1437, 2157, 3880, 3071, 3886, 4313, 4082, 115, 1192, 3352, 140, 2233, 1741, 2599, 1187, 356, 70, 4527, 4491, 1704, 458, 2927, 3612, 1465, 2873, 3448, 761, 1220, 513, 2623, 562, 433, 1080, 4533, 2095, 713, 873, 2744, 1935, 4603, 1918, 3040, 3331, 4857, 4344, 845, 4814, 2907, 3529, 2801, 366, 2278, 3572, 1634, 4718, 3, 2474, 4194, 2762, 2685, 3759, 2811, 3176, 4226, 486, 4198, 3609, 2082, 4696, 2028, 1444, 48, 2848, 1921, 277, 3397, 650, 4920, 319, 2152, 2273, 4863, 894, 3718, 4148, 380, 1531, 470, 2074, 3862, 4116, 3398, 278, 266, 4909, 2567, 3329, 2334, 3201, 768, 733, 1958, 984, 3483, 2809, 3270, 4539, 540, 3088, 2641, 2487, 4792, 2856, 3564, 4411, 50, 2302, 4818, 1970, 505, 61, 986, 936, 4682, 4886, 2194, 1711, 2154, 2214, 4339, 4298, 1996, 4950, 1849, 3091, 2999, 1551, 2267, 4852, 4492, 1212, 4636, 3692, 352, 3015, 4836, 2248, 1012, 2295, 978, 4235, 2829, 3997, 4900, 1545, 3790, 4055, 4779, 4885, 1808, 3707, 2230, 325, 3395, 671, 2892, 729, 1136, 3326, 719, 1475, 1385, 3709, 3496, 1934, 1892, 1120, 3460, 3181, 2955, 3754, 2644, 1400, 1230, 4610, 836, 4046, 2333, 929, 3027, 3433, 2130, 3586, 4916, 2126, 3050, 4835, 4602, 1873, 4091, 2227, 4367, 3102, 932, 4648, 3695, 2421, 2833, 63, 1265, 4596, 4279, 4674, 1620, 4108, 3637, 3848, 4128, 4763, 2448, 4932, 1252, 2040, 3399, 736, 3913, 109, 1865, 644, 2196, 4284, 680, 3234, 756, 3062, 3651, 2355, 3474, 3858, 4925, 1604, 575, 3700, 4861, 2977, 3731, 3022, 3531, 3605, 1142, 4237, 2640, 3114, 1824, 2070, 992, 1071, 4569, 1445, 3703, 557, 3771, 243, 3224, 2133, 1112, 1241, 3299, 3951, 3618, 2691, 4503, 1161, 3175, 338, 787, 4727, 1145, 3189, 2941, 3489, 3734, 3389, 4069, 654, 1588, 4911, 1710, 3768, 684, 2081, 220, 4464, 1473, 4183, 897, 3877, 550, 2330, 2790, 567, 2726, 506, 3639, 4933, 3863, 3239, 2197, 763, 4565, 2776, 2247, 464, 2563, 1093, 1928, 1980, 1658, 4912, 4438, 1316, 539, 2764, 1855, 1583, 4326, 2101, 1096, 2151, 2701, 770, 4876, 2734, 3418, 1066, 2201, 2496, 868, 3036, 4406, 303, 2150, 363, 3543, 1020, 592, 3047, 409, 1815, 3504, 2277, 811, 1078, 270, 1951, 1149, 2388, 2276, 182, 2301, 1713, 3248, 4166, 256, 1585, 1138, 1215, 3141, 2894, 333, 3431, 2555, 2549, 1903, 4142, 867, 2961, 837, 1650, 4928, 4113, 3947, 3954, 4806, 3928, 42, 1599, 3106, 2489, 519, 1171, 1622, 4436, 663, 1950, 2634, 1182, 3793, 833, 2136, 3713, 731, 939, 267, 3023, 1318, 2661, 2381, 1818, 797, 1509, 4356, 84, 952, 2978, 3677, 702, 183, 88, 69, 3055, 1026, 3592, 4895, 887, 1044, 290, 545, 4811, 2631, 4365, 2427, 1070, 1191, 4254, 2326, 2288, 1045, 1113, 1670, 4197, 920, 667, 803, 2031, 2499, 4676, 3936, 2139, 496, 2721, 268, 2478, 3977, 4947, 4272, 146, 2798, 3083, 4200, 4817, 4512, 913, 1249, 158, 4180, 2263, 24, 2245, 298, 2588, 119, 3165, 3414, 3507, 862, 2672, 3305, 2066, 3940, 2819, 1841, 2905, 1619, 2392, 1451, 2949, 709, 3487, 568, 599, 2297, 1649, 1234, 2666, 348, 2637, 3428, 3712, 3333, 4248, 2884, 1336, 531, 1041, 3216, 601, 4601, 3854, 4346, 2306, 1705, 2622, 921, 4400, 4221, 3179, 4686, 2437, 3786, 1032, 2633, 3762, 4164, 4432, 2065, 969, 285, 1257, 4269, 2035, 4057, 2841, 4553, 1491, 1163, 2974, 3492, 1846, 3256, 1678, 1427, 1311, 4833, 2508, 2182, 4896, 3590, 1262, 3124, 3698, 1282, 2783, 4123, 1916, 2708, 1897, 4552, 2211, 460, 4859, 4681, 4185, 1064, 3466, 323, 4687, 3161, 2658, 1054, 1965, 3743, 4488, 2758, 2461, 4662, 4588, 3032, 2918, 4757, 4918, 2323, 4532, 2331, 4707, 2733, 799, 2693, 1859, 3259, 2046, 3030, 2444, 3622, 3565, 4377, 1990, 4497, 3345, 2722, 359, 1810, 4715, 3309, 1648, 552, 2738, 2728, 3087, 4980, 553, 1603, 1617, 4395, 1752, 414, 854, 3593, 1636, 2686, 3917, 3782, 2652, 297, 4591, 4487, 397, 1687, 954, 849, 4044, 2013, 2401, 424, 4250, 3888, 3869, 4282, 890, 311, 4205, 4124, 1232, 4795, 3429, 1836, 3733, 583, 1074, 3929, 3260, 1698, 3659, 3131, 1816, 4196, 1383, 656, 4509, 228, 4506, 4146, 4352, 621, 2800, 4684, 1513, 3228, 2839, 367, 4838, 2688, 3294, 1347, 686, 3789, 3424, 3999, 3264, 2036, 1276, 4018, 980, 2016, 3363, 259, 3123, 3288, 1167, 2087, 4190, 491, 3631, 2639, 4268, 4832, 1602, 1027, 1140, 517, 2236, 4257, 863, 1548, 3785, 3069, 322, 454, 3058, 258, 1495, 1384, 1615, 835, 2422, 3362, 2115, 2237, 2880, 4315, 3368, 3450, 3453, 1348, 2022, 456, 3971, 2836, 1976, 3568, 3003, 1601, 4333, 179, 3283, 4897, 4526, 443, 4111, 3585, 1814, 3745, 3265, 3128, 3652, 1058, 394, 301, 4671, 167, 1469, 3170, 2299, 4824, 2635, 3163, 3846, 3443, 4575, 2032, 156, 4179, 745, 856, 820, 1341, 428, 3818, 2659, 3439, 1298, 3097, 4493, 1682, 1791, 4390, 79, 3301, 4463, 764, 76, 2627, 2540, 4849, 1025, 2715, 166, 1665, 2404, 4220, 217, 2226, 126, 3250, 2506, 4820, 2054, 3960, 934, 1756, 600, 3477, 1103, 623, 4924, 4004, 560, 1949, 476, 1664, 1575, 3641, 4007, 2189, 1946, 254, 4628, 1035, 4787, 1021, 1803, 4273, 4312, 1280, 4172, 1104, 1216, 4404, 304, 3829, 4295, 2562, 4397, 2166, 4417, 312, 4690, 4764, 4029, 1222, 4654, 1330, 2259, 4362, 4531, 4076, 3377, 2866, 4801, 893, 3413, 2778, 78, 1926, 3795, 4074, 4209, 3517, 1936, 389, 1407, 3104, 3595, 4551, 74, 2587, 694, 1424, 4729, 3987, 666, 2702, 1450, 965, 2500, 1924, 3203, 4158, 3401, 3077, 1568, 2749, 4080, 4027, 3337, 1987, 1193, 3317, 4894, 3099, 1542, 2570, 8, 3857, 4071, 3970, 1644, 457, 415, 3904, 3602, 4765, 3537, 3908, 2679, 1702, 1398, 3263, 4393, 3764, 2479, 4959, 2410, 3142, 1681, 3464, 3842, 3697, 2106, 651, 3026, 4000, 753, 1532, 1417, 3520, 524, 117, 707, 957, 721, 4277, 3760, 4451, 4778, 4518, 1888, 3580, 4058, 2788, 17, 2279, 4483, 3041, 2116, 2315, 264, 489, 499, 4370, 1418, 2213, 2311, 1706, 935, 2104, 3011, 1800, 737, 430, 1655, 4434, 1724, 2855, 1067, 3272, 3996, 2389, 2611, 985, 3696, 525, 2314, 987, 343, 2426, 2324, 2436, 2376, 3186, 1646, 2256, 4090, 4906, 3616, 3441, 538, 3554, 1088, 698, 1506, 1591, 2795, 350, 605, 3215, 4666, 973, 4110, 509, 2482, 798, 1750, 2896, 4391, 2356, 4034, 1370, 3313, 3446, 3881, 1948, 4969, 450, 4061, 2698, 1009, 2041, 3282, 1830, 3687, 2690, 1832, 293, 4955, 2594, 3346, 316, 1434, 931, 3984, 901, 4441, 1201, 2007, 2283, 1123, 2117, 2830, 2225, 1606, 191, 2435, 3664, 1984, 4804, 2943, 520, 1266, 3129, 2224, 2934, 4848, 3007, 185, 675, 4013, 223, 4776, 4642, 4701, 4854, 1770, 1912, 3382, 4754, 3006, 1375, 2816, 33, 4855, 4640, 1956, 649, 1582, 1535, 123, 4577, 2195, 3638, 4223, 3714, 4953, 2374, 1024, 2881, 2950, 3300, 664, 4981, 1275, 1443, 879, 4143, 1547, 4214, 3935, 3646, 4189, 1502, 11, 3644, 614, 966, 2984, 2605, 606, 1691, 769, 4228, 2845, 529, 3187, 2850, 2507, 2554, 3112, 1277, 4266, 1226, 2994, 2038, 786, 2630, 2060, 2477, 1382, 3323, 876, 3033, 3636, 4586, 3705, 1825, 1683, 3404, 4891, 4926, 1022, 1040, 915, 274, 4218, 3002, 2712, 801, 4361, 1154, 3758, 4442, 3788, 4655, 1780, 2061, 2019, 4453, 125, 1441, 73, 2187, 3838, 3164, 279, 4756, 919, 842, 1941, 2171, 2218, 3481, 596, 1598, 2483, 493, 1147, 2542, 1653, 1345, 825, 2384, 4943, 4858, 1101, 3183, 3410, 4513, 4448, 2015, 2424, 2026, 1166, 221, 1151, 2466, 1309, 1359, 556, 4791, 1131, 2235, 2888, 3694, 1848, 2463, 4064, 938, 4099, 4534, 2944, 3524, 3815, 1421, 636, 2193, 1233, 1310, 1073, 3897, 4167, 467, 2281, 2598, 4748, 4379, 3089, 3982, 3626, 3840, 1909, 625, 2103, 2626, 4181, 1174, 4177, 3802, 4797, 602, 2625, 4877, 4085, 4810, 4241, 2682, 1480, 4443, 1539, 1697, 4809, 615, 4504, 2646, 2155, 3420, 2840, 1492, 252, 2264, 1554, 4450, 1557, 1031, 2980, 2454, 746, 3720, 1401, 1320, 3670, 131, 3402, 2004, 742, 4758, 4865, 120, 3527, 573, 4540, 1616, 2045, 2322, 2468, 3335, 1238, 3535, 4679, 4294, 4505, 2411, 3901, 884, 305, 3394, 463, 4230, 480, 1169, 4363, 1446, 3010, 3510, 218, 51, 1496, 1124, 4777, 7, 1610, 2305, 4507, 3360, 2285, 927, 3550, 4026, 2058, 4286, 3916, 2457, 3167, 262, 4380, 3498, 4879, 4127, 2900, 3271, 4276, 2156, 3780, 1884, 447, 3671, 2380, 4720, 3169, 4348, 2847, 2494, 4768, 2781, 163, 807, 2107, 1584, 3090, 2017, 2913, 4536, 4479, 1061, 4201, 2846, 3578, 3316, 93, 286, 523, 1403, 2684, 3472, 586, 2910, 426, 2485, 2940, 112, 294, 3986, 1319, 99, 3503, 3872, 4242, 2008, 437, 3906, 4357, 895, 1581, 4191, 2768, 3293, 1776, 2923, 4416, 1189, 3107, 3144, 22, 925, 3763, 2178, 3303, 2650, 4946, 249, 3063, 2657, 2784, 1595, 1883, 2431, 2828, 3422, 3606, 4263, 758, 1657, 4425, 4445, 40, 1046, 1457, 3475, 3409, 502, 2393, 4456, 3885, 3831, 1307, 3289, 1225, 2129, 104, 2874, 3783, 3202, 2467, 2246, 176, 1522, 4274, 703, 3521, 4109, 3747, 462, 5, 320, 1879, 4704, 16, 1983, 288, 3147, 4408, 3629, 4104, 974, 3028, 1435, 4914, 4435, 2359, 2586, 4424, 4350, 321, 542, 4592, 4126, 211, 3098, 1406, 3149, 1185, 4709, 2596, 2308, 4638, 3839, 677, 2677, 13, 4775, 533, 1516, 782, 4680, 1203, 3470, 2613, 660, 4584, 1831, 3048, 168, 308, 2614, 3193, 4405, 738, 2609, 1742, 3699, 2143, 3025, 4837, 4480, 4296, 114, 26, 1856, 4103, 3285, 2827, 3688, 1692, 609, 4617, 2871, 2208, 1747, 2222, 2917, 3852, 1317, 643, 3979, 2296, 452, 604, 1300, 4637, 1493, 3898, 2891, 3407, 2452, 1394, 490, 81, 3978, 720, 1291, 3570, 3526, 3867, 3082, 1656, 3992, 3174, 1974, 1895, 2541, 2451, 108, 1173, 85, 549, 105, 3746, 32, 345, 3391, 603, 861, 2438, 1486, 2674, 2163, 3706, 3461, 3800, 4466, 781, 2651, 4041, 4798, 855, 4233, 55, 4360, 4677, 3810, 1890, 4819, 2716, 3891, 2492, 771, 4037, 4204, 2077, 3073, 772, 1430, 3231, 3851, 4025, 1264, 4630, 4030, 3679, 83, 4468, 3108, 2419, 3244, 189, 3198, 1077, 3569, 4812, 1878, 4398, 3727, 3411, 2328, 904, 3843, 676, 1134, 2676, 4889, 580, 2785, 360, 4366, 926, 1919, 1297, 497, 3351, 1999, 4987, 4270, 1894, 3476, 3864, 2514, 71, 2244, 2029, 4672, 1510, 1419, 1195, 4159, 2804, 3370, 1313, 3614, 4525, 3948, 2550, 2709, 381, 933, 1994, 1668, 2407, 2398, 4823, 1063, 4606, 47, 754, 1538, 4972, 2280, 4660, 188, 342, 4983, 3325, 472, 2671, 4062, 2518, 1053, 4734, 3738, 1570, 4936, 1915, 2648, 4243, 172, 2763, 1863, 4749, 808, 670, 3634, 3230, 2553, 2183, 327, 3200, 3744, 3663, 2329, 3339, 4384, 4785, 4917, 1763, 3962, 2838, 3914, 1576, 608, 144, 563, 371, 2205, 1360, 908, 3742, 3647, 3628, 4188, 2124, 3942, 3019, 4336, 3596, 3459, 2808, 388, 1975, 3640, 492, 4386, 1523, 3599, 783, 2242, 4599, 80, 858, 2200, 844, 2216, 1086, 3574, 2834, 1259, 3416, 1544, 1937, 329, 1587, 2534, 1152, 2948, 682, 4627, 4590, 3882, 3769, 3690, 4322, 2385, 2416, 2354, 3560, 1714, 229, 1989, 2123, 1693, 2252, 4990, 4893, 652, 554, 2371, 3445, 1373, 1799, 1324, 3493, 3497, 3773, 4786, 404, 3463, 403, 4759, 488, 2632, 2240, 2786, 2192, 2601, 2885, 2890, 3648, 1371, 2241, 4341, 1659, 4635, 4703, 964, 4066, 3056, 2177, 4117, 3876, 370, 1621, 2057, 1456, 4135, 3306, 2720, 4332, 948, 2352, 697, 726, 3425, 1011, 2607, 724, 203, 421, 2358, 4760, 3767, 3400, 448, 3719, 1923, 3591, 516, 2615, 3945, 1030, 4781, 4755, 2044, 914, 1751, 1555, 2806, 2595, 4788, 4968, 2455, 281, 2417, 4155, 1490, 4077, 482, 1270, 1900, 3519, 2408, 4839, 4249, 4845, 1612, 4340, 1637, 2012, 4439, 2188, 727, 3993, 838, 1414, 1778, 3824, 2370, 3122, 273, 3458, 1885, 4732, 2528, 647, 1415, 976, 4622, 15, 1479, 2681, 4305, 2820, 4771, 400, 3765, 2737, 3049, 4907, 2260, 1005, 1881, 2199, 4919, 2979, 174, 3117, 2120, 701, 4207, 2960, 2406, 3437, 3772, 1376, 4805, 1236, 4700, 4119, 3074, 2747, 1574, 3770, 3513, 2717, 3052, 2282, 2536, 3820, 2906, 577, 2034, 613, 3711, 2696, 3086, 4387, 3092, 330, 500, 150, 1122, 4548, 4285, 3084, 3555, 2539, 2618, 439, 344, 3018, 3701, 4922, 64, 1004, 1245, 4583, 2415, 62, 4572, 2967, 1629, 2251, 2430, 3766, 4255, 2464, 1694, 4816, 1099, 543, 4661, 3894, 1674, 1853, 275, 142, 4938, 206, 1787, 3103, 4139, 3277, 1643, 4892, 990, 3905, 4473, 1997, 4683, 1517, 2662, 4619, 416, 2823, 2779, 918, 4265, 4692, 1006, 3221, 1623, 2986, 1351, 1722, 157, 2515, 3630, 3778, 2532, 4244, 1536, 2232, 3515, 2212, 4979, 3683, 379, 4033, 216, 2076, 2497, 534, 3723, 512, 466, 2670, 2531, 4376, 1362, 4500, 98, 4275, 284, 4003, 1488, 1352, 4620, 630, 196, 2047, 4722, 4934, 633, 1242, 1783, 3350, 2271, 1695, 526, 92, 3861, 888, 829, 4131, 3261, 3658, 961, 3735, 1774, 2268, 518, 4544, 95, 3866, 4460, 4157, 4314, 2338, 1969, 1484, 1098, 3643, 2908, 1845, 4499, 1732, 1869, 2628, 390, 522, 1175, 3792, 1788, 4324, 767, 1133, 4217, 1820, 1059, 3153, 1355, 843, 309, 899, 4789, 582, 4021, 4238, 3173, 127, 4691, 3338, 780, 1985, 3553, 3029, 2757, 2939, 2079, 4262, 429, 2604, 2396, 3386, 3192, 2600, 1870, 1197, 2088, 4878, 2207, 4319, 276, 891, 4353, 4875, 2434, 2530, 2835, 4502, 3225, 1973, 1739, 1953, 3516, 4458, 616, 2228, 3530, 3508, 951, 2985, 1947, 1158, 1786, 3427, 1387, 2735, 4511, 790, 2877, 906, 4059, 1279, 1766, 2100, 3447, 233, 2440, 2663, 4782, 2924, 1701, 1501, 4564, 4726, 1258, 3162, 4081, 382, 2547, 4446, 3620, 4843, 3214, 2206, 4320, 4793, 4137, 4105, 2512, 1083, 865, 1671, 2386, 3208, 4647, 1589, 1559, 2590, 1618, 1771, 1459, 3342, 295, 2956, 4154, 2253, 1565, 56, 242, 1155, 4616, 1207, 2831, 1733, 4573, 3024, 1905, 2988, 3822, 3330, 1338, 3159, 700, 121, 2062, 4614, 1998, 2181, 1871, 717, 2584, 4576, 4957, 2928, 740, 4888, 3540, 3308, 922, 3666, 4147, 4150, 2807, 3276, 1062, 665, 4342, 3209, 732, 2767, 2921, 3366, 4345, 4163, 2470, 164, 2565, 2654, 3365, 1726, 4840, 3034, 147, 2339, 617, 357, 1640, 3468, 4658, 1562, 2353, 4989, 4613, 4659, 1422, 2203, 3532, 4978, 2265, 3127, 2128, 1293, 2886, 141, 4042, 511, 3623, 1017, 3222, 353, 1119, 898, 2473, 2882, 2412, 735, 1049, 4335, 4470, 1244, 634, 1254, 1614, 4001, 1485, 4141, 3949, 369, 4558, 468, 155, 1844, 1760, 527, 4302, 1689, 2175, 419, 975, 4597, 1325, 231, 4724, 4043, 3014, 1328, 2581, 2346, 2782, 4195, 3430, 2719, 1321, 1500, 1141, 1255, 911, 4770, 1467, 2552, 2545, 503, 2692, 2184, 3806, 4261, 2995, 2571, 3432, 4084, 1748, 784, 1807, 3396, 4537, 3252, 3290, 449, 2219, 4869, 1168, 4410, 2340, 230, 3776, 4297, 4096, 1092, 657, 774, 4112, 2964, 2673, 3966, 2480, 250, 2210, 1533, 4560, 4960, 4454, 373, 2982, 956, 1645, 2592, 2462, 4542, 679, 4694, 2826, 1248, 4006, 765, 2649, 4481, 2001, 2400, 3991, 485, 1550, 461, 4100, 2011, 289, 3976, 4101, 1109, 1139, 4808, 4656, 1773, 134, 3512, 324, 1893, 138, 2072, 4985, 118, 2471, 730, 547, 4186, 1110, 3980, 1117, 569, 4049, 1130, 2564, 3995, 3334, 4094, 1630, 4794 ]

  e_median, e_medians = (8992, [2098 => 14, 2220 => 20, 2262 => 6, 2270 => 20, 2274 => 62, 2293 => 29, 2294 => 42, 2327 => 52, 2347 => 15, 2351 => 35, 2368 => 19, 2372 => 4, 2375 => 45, 2379 => 20, 2382 => 19, 2387 => 8, 2399 => 18, 2414 => 84, 2429 => 37, 2432 => 37, 2439 => 109, 2443 => 45, 2447 => 132, 2456 => 92, 2459 => 71, 2465 => 51, 2469 => 1, 2472 => 66, 2474 => 19, 2475 => 34, 2476 => 85, 2478 => 21, 2481 => 55, 2484 => 98, 2486 => 204, 2487 => 65, 2488 => 159, 2489 => 46, 2490 => 199, 2491 => 89, 2493 => 143, 2494 => 32, 2495 => 132, 2496 => 125, 2498 => 323, 2499 => 172, 2500 => 137, 2501 => 308, 2502 => 385, 2503 => 350, 2504 => 223, 2505 => 175, 2506 => 80, 2507 => 34, 2508 => 23, 2509 => 56, 2510 => 2, 2511 => 9, 2513 => 33, 2516 => 11, 2520 => 4, 2523 => 1, 2729 => 4, 3130 => 8, 3534 => 3])

  @test median_maint(inp; with_medians=true) == (e_median, e_medians)
end

@testset "median problem11.3 tests" begin
  exp_medians = sort(collect(Dict{Int, Int}(6331 => 1, 2793 => 6, 1640 => 1, 2303 => 2)))
  @test median_maint("testfiles/problem11.3test.txt"; with_medians=true) == (9335, exp_medians)
end

@testset "median problem11.3.txt" begin
  exp_medians = [1640 => 1, 2303 => 2, 2793 => 9, 3480 => 9, 3505 => 2, 3555 => 10, 3611 => 17, 3719 => 6, 3912 => 31, 3932 => 37, 4135 => 19, 4154 => 4, 4164 => 17, 4181 => 15, 4194 => 5, 4200 => 43, 4229 => 51, 4231 => 5, 4232 => 12, 4239 => 76, 4249 => 59, 4256 => 7, 4273 => 21, 4275 => 27, 4277 => 73, 4281 => 28, 4289 => 122, 4292 => 103, 4308 => 52, 4312 => 85, 4315 => 87, 4319 => 60, 4321 => 23, 4329 => 34, 4333 => 40, 4345 => 38, 4348 => 67, 4351 => 45, 4352 => 46, 4356 => 3, 4357 => 25, 4358 => 24, 4360 => 41, 4368 => 58, 4392 => 13, 4403 => 31, 4405 => 50, 4414 => 45, 4417 => 43, 4424 => 45, 4429 => 29, 4437 => 32, 4438 => 6, 4442 => 31, 4445 => 11, 4447 => 13, 4448 => 47, 4450 => 58, 4456 => 48, 4462 => 36, 4465 => 28, 4466 => 45, 4468 => 30, 4469 => 5, 4470 => 25, 4472 => 2, 4473 => 17, 4479 => 26, 4480 => 43, 4481 => 94, 4482 => 54, 4483 => 107, 4484 => 129, 4485 => 31, 4486 => 87, 4489 => 17, 4492 => 50, 4497 => 9, 4501 => 33, 4502 => 3, 4503 => 23, 4504 => 16, 4513 => 32, 4514 => 52, 4521 => 40, 4523 => 6, 4524 => 23, 4526 => 22, 4527 => 29, 4528 => 22, 4531 => 14, 4533 => 19, 4534 => 2, 4536 => 4, 4537 => 2, 4538 => 2, 4540 => 2, 4541 => 8, 4544 => 20, 4557 => 34, 4561 => 20, 4564 => 14, 4571 => 12, 4572 => 4, 4573 => 2, 4578 => 2, 4582 => 3, 4583 => 3, 4588 => 11, 4591 => 16, 4594 => 4, 4596 => 9, 4598 => 25, 4599 => 24, 4602 => 19, 4605 => 29, 4608 => 18, 4614 => 36, 4615 => 59, 4618 => 32, 4619 => 4, 4621 => 32, 4625 => 42, 4630 => 63, 4631 => 75, 4633 => 63, 4636 => 34, 4637 => 21, 4639 => 13, 4643 => 5, 4644 => 7, 4647 => 20, 4648 => 62, 4651 => 58, 4652 => 53, 4653 => 81, 4654 => 59, 4655 => 20, 4658 => 2, 4663 => 11, 4668 => 16, 4669 => 22, 4672 => 18, 4674 => 36, 4675 => 36, 4676 => 25, 4678 => 5, 4682 => 9, 4688 => 14, 4689 => 23, 4691 => 34, 4696 => 27, 4698 => 16, 4699 => 6, 4703 => 2, 4705 => 4, 4706 => 10, 4707 => 11, 4708 => 8, 4709 => 23, 4710 => 24, 4711 => 18, 4712 => 25, 4714 => 47, 4716 => 80, 4717 => 60, 4722 => 33, 4723 => 32, 4724 => 19, 4725 => 23, 4726 => 13, 4727 => 29, 4729 => 25, 4730 => 6, 4731 => 7, 4732 => 12, 4733 => 32, 4734 => 30, 4737 => 32, 4740 => 11, 4741 => 2, 4747 => 4, 4748 => 25, 4749 => 35, 4750 => 49, 4751 => 23, 4753 => 6, 4754 => 4, 4760 => 13, 4761 => 5, 4763 => 2, 4764 => 10, 4765 => 8, 4768 => 2, 4771 => 2, 4774 => 2, 4775 => 5, 4776 => 3, 4780 => 12, 4783 => 18, 4784 => 6, 4785 => 6, 4786 => 14, 4787 => 25, 4790 => 3, 4791 => 9, 4792 => 18, 4793 => 18, 4795 => 21, 4796 => 18, 4798 => 7, 4799 => 5, 4800 => 2, 4801 => 3, 4803 => 11, 4804 => 13, 4806 => 13, 4807 => 43, 4809 => 68, 4810 => 52, 4811 => 28, 4813 => 30, 4814 => 28, 4816 => 16, 4818 => 5, 4819 => 7, 4821 => 7, 4822 => 11, 4824 => 18, 4825 => 29, 4826 => 45, 4827 => 65, 4828 => 74, 4829 => 29, 4830 => 11, 4831 => 5, 4833 => 8, 4837 => 4, 4839 => 12, 4840 => 36, 4841 => 57, 4843 => 63, 4847 => 31, 4848 => 17, 4849 => 32, 4851 => 60, 4852 => 57, 4854 => 55, 4856 => 47, 4857 => 52, 4859 => 62, 4860 => 78, 4861 => 60, 4862 => 28, 4863 => 13, 4864 => 23, 4865 => 23, 4867 => 35, 4868 => 23, 4869 => 6, 4870 => 13, 4872 => 10, 4873 => 4, 4874 => 7, 4877 => 3, 4883 => 7, 4884 => 18, 4885 => 34, 4886 => 24, 4887 => 18, 4889 => 26, 4891 => 31, 4892 => 11, 4893 => 11, 4895 => 6, 4896 => 3, 4898 => 17, 4899 => 28, 4900 => 41, 4901 => 20, 4903 => 10, 4904 => 26, 4905 => 20, 4906 => 10, 4907 => 15, 4908 => 30, 4909 => 37, 4910 => 31, 4911 => 22, 4913 => 14, 4914 => 8, 4915 => 24, 4916 => 13, 4918 => 4, 4920 => 12, 4921 => 14, 4922 => 7, 4923 => 17, 4925 => 9, 4926 => 10, 4928 => 10, 4929 => 17, 4930 => 10, 4931 => 15, 4932 => 7, 4934 => 3, 4935 => 3, 4937 => 5, 4938 => 4, 4942 => 8, 4943 => 4, 4944 => 7, 4945 => 6, 4946 => 5, 4947 => 7, 4949 => 10, 4950 => 7, 4951 => 7, 4952 => 8, 4953 => 16, 4954 => 15, 4955 => 19, 4956 => 16, 4957 => 31, 4958 => 41, 4959 => 39, 4960 => 62, 4961 => 105, 4962 => 144, 4964 => 100, 4965 => 64, 4966 => 53, 4968 => 48, 4969 => 34, 4970 => 9, 4971 => 16, 4972 => 39, 4973 => 79, 4974 => 36, 4975 => 3, 4976 => 2, 4977 => 2, 4979 => 2, 4982 => 7, 4983 => 7, 4984 => 2, 4985 => 2, 4987 => 11, 4988 => 12, 4989 => 4, 4990 => 6, 4991 => 14, 4994 => 51, 4995 => 56, 4996 => 48, 4997 => 2, 4998 => 49, 4999 => 76, 5000 => 29, 5001 => 104, 5002 => 65, 5003 => 109, 5004 => 76, 5005 => 131, 5006 => 80, 5007 => 55, 5008 => 24, 5009 => 22, 5010 => 35, 5011 => 9, 5147 => 1, 6331 => 1]

  @test median_maint("testfiles/problem11.3.txt"; with_medians=true) == (1213, exp_medians)
end
