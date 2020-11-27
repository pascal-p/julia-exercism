using Test
# using Random

include("./src/karger_mincut.jl")
include("./utils/file.jl")
include("./utils/runner.jl")

const TF_DIR = "./testfiles"

function gen_adj()
  a = slurp("$(TF_DIR)/karger_mincut.txt")
  Dict([x[1] => x[2:end] for x in a])
end

@testset "mincut file - 200 nodes" begin

  @testset "5_000 runs" begin
    adjl = gen_adj()
    gr = UnGraph{Int}(adjl)

    @time (k, res) = runner(gr; n=5_000, seed=42)
    @test k == 17

    println("Stats run: $(res)")
  end

end

# 20_000 iterations, seed: 42, ...
# 436.506289 seconds (2.13 G allocations: 298.581 GiB, 2.09% gc time)
# Test Summary:           | Pass  Total
# mincut file - 200 nodes |    1      1
# real    7m18.331s
# user    7m18.561s
# sys     0m0.536s

# 10_000 iterations, seed: 42, ...
# 219.958205 seconds (1.06 G allocations: 149.297 GiB, 2.09% gc time)
# Test Summary:           | Pass  Total
# mincut file - 200 nodes |    1      1
# real    3m41.827s
# user    3m42.150s
# sys     0m0.505s


# 5_000 iterations, seed: 42, ...
# 107.656573 seconds (531.76 M allocations: 74.649 GiB, 2.03% gc time)
# Stats run: Dict{Integer,Real}(306 => 0.0004,1090 => 0.001,29 => 0.0024,1131 => 0.0022,74 => 0.0006,905 => 0.001,176 => 0.0014,892 => 0.0004,285 => 0.001,318 => 0.0016,1124 => 0.002,1273 => 0.0002,873 => 0.0002,975 => 0.0006,354 => 0.0012,610 => 0.0004,563 => 0.0006,1082 => 0.001,880 => 0.001,1194 => 0.0008,671 => 0.0002,721 => 0.0008,930 => 0.0006,117 => 0.0004,1195 => 0.001,284 => 0.0008,1144 => 0.001,1116 => 0.0008,589 => 0.0004,188 => 0.0008,782 => 0.0004,621 => 0.0004,617 => 0.0006,353 => 0.0002,797 => 0.0002,430 => 0.0004,1166 => 0.001,79 => 0.001,71 => 0.0012,154 => 0.0012,1127 => 0.0012,184 => 0.0002,794 => 0.0002,908 => 0.0006,845 => 0.0012,733 => 0.0008,107 => 0.0004,416 => 0.0016,682 => 0.0004,294 => 0.0004,642 => 0.0006,606 => 0.0004,162 => 0.0008,881 => 0.001,240 => 0.0006,974 => 0.0014,917 => 0.0014,966 => 0.0008,980 => 0.0002,261 => 0.0014,1102 => 0.0008,514 => 0.0002,1146 => 0.001,840 => 0.0004,41 => 0.0014,1230 => 0.0004,461 => 0.001,148 => 0.0006,1097 => 0.0012,776 => 0.0004,1135 => 0.002,957 => 0.001,66 => 0.0008,573 => 0.0004,512 => 0.0008,1158 => 0.0014,95 => 0.001,236 => 0.0004,90 => 0.0014,111 => 0.001,844 => 0.0004,933 => 0.0002,396 => 0.0006,256 => 0.0002,1136 => 0.0018,1201 => 0.0012,1017 => 0.0008,1141 => 0.0004,592 => 0.001,973 => 0.0006,1052 => 0.0022,655 => 0.0002,565 => 0.0012,1199 => 0.0004,763 => 0.0002,620 => 0.0006,1240 => 0.0004,549 => 0.0008,135 => 0.0012,125 => 0.0006,1148 => 0.0012,965 => 0.0016,146 => 0.0004,130 => 0.0006,545 => 0.001,660 => 0.0008,1062 => 0.0004,453 => 0.0004,1100 => 0.0008,1247 => 0.0002,110 => 0.0002,309 => 0.0006,99 => 0.0006,1150 => 0.0016,981 => 0.0008,525 => 0.0008,1029 => 0.0002,899 => 0.0008,366 => 0.0006,556 => 0.0006,128 => 0.0004,348 => 0.0006,831 => 0.0006,736 => 0.0002,183 => 0.0006,591 => 0.0002,522 => 0.0008,860 => 0.0006,1179 => 0.0008,103 => 0.0004,931 => 0.0006,345 => 0.0006,742 => 0.0006,1043 => 0.0014,723 => 0.0004,843 => 0.0006,730 => 0.0006,982 => 0.0008,732 => 0.0002,941 => 0.0014,667 => 0.0002,911 => 0.0012,1003 => 0.0004,832 => 0.001,1008 => 0.0004,846 => 0.0004,454 => 0.0004,191 => 0.001,312 => 0.0004,663 => 0.0002,446 => 0.0004,751 => 0.0004,918 => 0.001,276 => 0.0012,659 => 0.0006,508 => 0.0006,1074 => 0.0002,241 => 0.0004,370 => 0.0008,197 => 0.001,1072 => 0.0004,654 => 0.0006,593 => 0.0002,624 => 0.0002,142 => 0.0006,1049 => 0.0012,935 => 0.001,848 => 0.0008,956 => 0.0018,1055 => 0.0008,718 => 0.0002,818 => 0.001,372 => 0.0004,612 => 0.001,433 => 0.0004,664 => 0.0008,1107 => 0.0018,677 => 0.0002,279 => 0.0008,700 => 0.0006,368 => 0.0004,609 => 0.0002,1191 => 0.0016,885 => 0.001,1227 => 0.0002,922 => 0.0008,890 => 0.0004,958 => 0.0004,916 => 0.0012,672 => 0.0004,1228 => 0.0006,963 => 0.0012,94 => 0.0008,290 => 0.0004,115 => 0.0008,607 => 0.0004,418 => 0.0008,373 => 0.0004,171 => 0.001,824 => 0.0004,455 => 0.0004,750 => 0.0004,334 => 0.0006,641 => 0.0012,1091 => 0.0012,178 => 0.0022,426 => 0.0004,1211 => 0.0008,1098 => 0.0008,503 => 0.001,313 => 0.0004,493 => 0.0002,577 => 0.0008,113 => 0.0014,293 => 0.001,914 => 0.0006,859 => 0.0002,1209 => 0.0012,297 => 0.0006,507 => 0.0016,1288 => 0.0002,471 => 0.0002,393 => 0.0006,497 => 0.0006,1177 => 0.0008,1167 => 0.0008,274 => 0.0012,1073 => 0.0004,1118 => 0.0006,28 => 0.0048,1115 => 0.0018,634 => 0.0012,1255 => 0.0002,1252 => 0.0002,97 => 0.001,584 => 0.0002,377 => 0.0004,39 => 0.0012,1018 => 0.001,58 => 0.0004,1044 => 0.001,867 => 0.0018,739 => 0.0008,333 => 0.0008,1114 => 0.0012,428 => 0.0006,254 => 0.0012,635 => 0.0008,185 => 0.0006,628 => 0.0002,20 => 0.0366,868 => 0.0008,1134 => 0.0016,849 => 0.0006,774 => 0.0006,266 => 0.0006,451 => 0.0006,166 => 0.0006,1126 => 0.0012,397 => 0.0002,35 => 0.0002,1157 => 0.0008,1109 => 0.0004,1054 => 0.0004,816 => 0.0002,286 => 0.001,145 => 0.0004,392 => 0.0006,554 => 0.0006,346 => 0.0012,1064 => 0.0008,86 => 0.0006,126 => 0.0006,1233 => 0.0012,587 => 0.0002,303 => 0.0006,82 => 0.0002,567 => 0.0002,75 => 0.0006,872 => 0.001,883 => 0.001,701 => 0.0002,237 => 0.001,87 => 0.0008,594 => 0.0014,386 => 0.0008,510 => 0.0016,613 => 0.0008,947 => 0.0004,347 => 0.0006,1213 => 0.0008,517 => 0.0006,949 => 0.0002,523 => 0.0008,1059 => 0.0006,504 => 0.0006,98 => 0.0012,666 => 0.0004,792 => 0.0002,1101 => 0.0008,540 => 0.0012,161 => 0.001,952 => 0.0002,389 => 0.001,22 => 0.0194,73 => 0.0006,119 => 0.0006,598 => 0.0004,222 => 0.0004,562 => 0.0008,53 => 0.0014,646 => 0.0004,580 => 0.0006,687 => 0.0002,869 => 0.0006,640 => 0.0002,502 => 0.001,498 => 0.0008,305 => 0.0008,745 => 0.0002,603 => 0.0002,27 => 0.006,134 => 0.0008,215 => 0.0008,1248 => 0.0004,131 => 0.0008,882 => 0.001,249 => 0.001,391 => 0.0002,207 => 0.0008,173 => 0.0004,542 => 0.0006,499 => 0.0006,477 => 0.0004,1151 => 0.0006,876 => 0.001,31 => 0.0024,1015 => 0.0012,625 => 0.001,70 => 0.0014,597 => 0.0008,1129 => 0.001,886 => 0.0006,1218 => 0.0014,1189 => 0.0004,1117 => 0.002,1031 => 0.0014,473 => 0.0002,1060 => 0.0008,327 => 0.001,511 => 0.0002,1170 => 0.0012,1164 => 0.0014,978 => 0.001,230 => 0.0004,780 => 0.0008,951 => 0.001,773 => 0.0004,720 => 0.001,50 => 0.0012,513 => 0.0008,326 => 0.0006,80 => 0.0008,248 => 0.0006,1216 => 0.0012,412 => 0.0006,447 => 0.0004,555 => 0.0006,1188 => 0.0008,401 => 0.0006,217 => 0.0008,855 => 0.001,786 => 0.0002,506 => 0.0006,120 => 0.0008,822 => 0.0006,681 => 0.0004,167 => 0.001,903 => 0.0002,143 => 0.0004,1076 => 0.001,62 => 0.0006,21 => 0.0188,996 => 0.0014,1094 => 0.0016,548 => 0.0002,280 => 0.0012,260 => 0.0012,961 => 0.0016,761 => 0.0004,251 => 0.0006,1174 => 0.001,463 => 0.0008,1250 => 0.0002,649 => 0.0008,438 => 0.0004,656 => 0.0004,766 => 0.0004,757 => 0.0002,699 => 0.0004,55 => 0.0004,1034 => 0.0008,909 => 0.0004,155 => 0.0008,569 => 0.0006,694 => 0.0014,709 => 0.0002,728 => 0.0002,344 => 0.0014,787 => 0.0004,747 => 0.0006,929 => 0.0016,253 => 0.0004,1079 => 0.0006,258 => 0.0004,483 => 0.0004,205 => 0.0002,1161 => 0.0002,1120 => 0.001,815 => 0.0004,269 => 0.0008,452 => 0.0004,492 => 0.0008,65 => 0.001,202 => 0.0006,44 => 0.003,324 => 0.0002,1056 => 0.0004,192 => 0.0012,729 => 0.0002,858 => 0.0002,1080 => 0.0006,270 => 0.0004,901 => 0.0006,647 => 0.001,137 => 0.0006,339 => 0.0008,105 => 0.0006,765 => 0.0004,800 => 0.001,307 => 0.0002,1027 => 0.0004,379 => 0.0008,352 => 0.001,273 => 0.0004,1143 => 0.0012,1032 => 0.0018,38 => 0.0004,118 => 0.0008,648 => 0.0008,553 => 0.0004,1223 => 0.0008,570 => 0.0006,826 => 0.0002,821 => 0.0004,1182 => 0.0004,715 => 0.0002,100 => 0.0006,411 => 0.0006,904 => 0.0006,81 => 0.0008,790 => 0.0004,1159 => 0.0016,268 => 0.0008,243 => 0.0008,535 => 0.0006,424 => 0.0002,317 => 0.0008,1084 => 0.0014,676 => 0.0008,163 => 0.0002,861 => 0.0006,108 => 0.001,1105 => 0.001,1053 => 0.0004,329 => 0.0004,89 => 0.0014,924 => 0.0012,1128 => 0.0006,755 => 0.0002,144 => 0.0008,735 => 0.0002,1239 => 0.0006,400 => 0.0006,788 => 0.0002,1067 => 0.0006,375 => 0.0004,494 => 0.0006,893 => 0.0002,1024 => 0.0002,112 => 0.0004,1014 => 0.0008,544 => 0.001,106 => 0.0008,26 => 0.0132,1153 => 0.0008,387 => 0.0008,350 => 0.0002,823 => 0.0006,440 => 0.0014,622 => 0.0008,585 => 0.0006,834 => 0.0006,54 => 0.0012,101 => 0.0002,897 => 0.0008,337 => 0.0002,60 => 0.0008,34 => 0.001,481 => 0.0002,1051 => 0.0008,467 => 0.0004,762 => 0.001,238 => 0.0004,674 => 0.001,627 => 0.0002,936 => 0.0006,295 => 0.0004,1092 => 0.0004,1226 => 0.0002,912 => 0.0002,1204 => 0.001,242 => 0.0008,810 => 0.0012,189 => 0.001,775 => 0.0002,398 => 0.0012,575 => 0.0006,913 => 0.001,875 => 0.001,805 => 0.0008,208 => 0.0014,896 => 0.0002,1019 => 0.0002,1254 => 0.0004,380 => 0.0006,72 => 0.0012,1041 => 0.0014,1168 => 0.0026,653 => 0.0006,988 => 0.0006,362 => 0.0006,68 => 0.0012,643 => 0.0014,275 => 0.0014,46 => 0.0024,382 => 0.0002,724 => 0.0006,938 => 0.0004,547 => 0.0004,1111 => 0.001,199 => 0.0004,323 => 0.0008,995 => 0.001,247 => 0.0006,1005 => 0.0004,631 => 0.0008,669 => 0.0004,1121 => 0.0012,406 => 0.0004,652 => 0.0008,683 => 0.001,852 => 0.0004,232 => 0.0004,994 => 0.0004,355 => 0.0006,1243 => 0.0002,749 => 0.0006,187 => 0.0006,83 => 0.001,1149 => 0.0012,1198 => 0.0004,539 => 0.001,814 => 0.0012,487 => 0.0006,541 => 0.0012,45 => 0.0022,753 => 0.0006,954 => 0.0008,662 => 0.0002,1192 => 0.0018,1039 => 0.0006,808 => 0.0008,1078 => 0.0006,442 => 0.0004,976 => 0.0008,595 => 0.0008,743 => 0.0002,1023 => 0.0008,1219 => 0.0004,546 => 0.0006,972 => 0.0002,1075 => 0.0006,945 => 0.0008,754 => 0.0004,376 => 0.0002,684 => 0.0004,61 => 0.001,1048 => 0.0012,500 => 0.0006,710 => 0.0006,383 => 0.0004,431 => 0.0006,409 => 0.0004,862 => 0.0004,870 => 0.0004,1160 => 0.0014,304 => 0.0006,476 => 0.0008,629 => 0.0004,361 => 0.0008,772 => 0.0008,415 => 0.0006,1030 => 0.0002,706 => 0.0002,1104 => 0.001,423 => 0.0004,271 => 0.0006,1106 => 0.0008,714 => 0.001,23 => 0.007,1152 => 0.001,315 => 0.0002,841 => 0.001,1215 => 0.0008,288 => 0.0006,1050 => 0.0006,712 => 0.0002,300 => 0.001,1000 => 0.0004,289 => 0.0012,435 => 0.0004,57 => 0.0002,1169 => 0.0006,1232 => 0.0004,799 => 0.0008,704 => 0.0004,690 => 0.0004,445 => 0.0006,779 => 0.0006,252 => 0.0008,921 => 0.0002,96 => 0.0008,727 => 0.0002,803 => 0.0008,49 => 0.0022,819 => 0.0008,552 => 0.0004,898 => 0.0012,534 => 0.001,559 => 0.0008,716 => 0.0004,227 => 0.0002,1155 => 0.0012,515 => 0.0002,195 => 0.0004,157 => 0.0008,264 => 0.0014,984 => 0.0004,221 => 0.0004,153 => 0.0012,697 => 0.0006,579 => 0.0006,590 => 0.0008,1085 => 0.0006,619 => 0.0004,484 => 0.0008,169 => 0.0004,1154 => 0.0008,1089 => 0.002,129 => 0.0004,88 => 0.0008,429 => 0.0004,937 => 0.0006,149 => 0.0006,439 => 0.0004,1004 => 0.0008,529 => 0.0004,630 => 0.0004,557 => 0.0016,501 => 0.0006,245 => 0.0004,574 => 0.0006,210 => 0.0004,1119 => 0.0018,495 => 0.0012,734 => 0.001,566 => 0.001,1007 => 0.0006,962 => 0.0012,150 => 0.0012,209 => 0.0012,789 => 0.0004,888 => 0.0012,175 => 0.0002,200 => 0.001,308 => 0.0004,543 => 0.0004,172 => 0.0006,314 => 0.0006,987 => 0.0008,583 => 0.0008,970 => 0.001,394 => 0.0004,596 => 0.001,419 => 0.0004,436 => 0.0006,793 => 0.0006,967 => 0.0006,942 => 0.0008,450 => 0.0002,953 => 0.0006,141 => 0.0012,216 => 0.0008,30 => 0.0026,47 => 0.0022,214 => 0.0006,944 => 0.0002,91 => 0.0006,470 => 0.0008,147 => 0.0008,639 => 0.0004,1123 => 0.0004,244 => 0.0004,1108 => 0.0006,1186 => 0.0008,693 => 0.0004,1173 => 0.0004,488 => 0.0006,829 => 0.0004,1224 => 0.0002,863 => 0.0008,785 => 0.0002,560 => 0.0008,688 => 0.0002,950 => 0.0006,378 => 0.0008,51 => 0.0012,177 => 0.0006,759 => 0.0006,123 => 0.0006,657 => 0.0004,427 => 0.0004,1256 => 0.0002,358 => 0.0006,661 => 0.0006,740 => 0.0004,581 => 0.0008,713 => 0.0006,1026 => 0.001,532 => 0.0006,658 => 0.0006,1132 => 0.0012,365 => 0.0004,771 => 0.001,825 => 0.0008,907 => 0.001,509 => 0.0002,986 => 0.0008,521 => 0.0004,407 => 0.0006,1181 => 0.0014,616 => 0.0008,1058 => 0.0006,874 => 0.0006,820 => 0.0008,817 => 0.0012,182 => 0.0014,1083 => 0.0022,1093 => 0.0022,138 => 0.0006,964 => 0.0004,518 => 0.0008,866 => 0.0012,235 => 0.0008,673 => 0.0004,971 => 0.0008,1112 => 0.0006,1229 => 0.0004,40 => 0.002,1065 => 0.0008,838 => 0.0006,417 => 0.0006,1156 => 0.0012,891 => 0.001,1200 => 0.0008,1212 => 0.0012,842 => 0.0004,884 => 0.0014,1016 => 0.0006,1147 => 0.002,343 => 0.0004,410 => 0.0002,626 => 0.0004,770 => 0.0006,246 => 0.0006,364 => 0.0008,764 => 0.0002,1231 => 0.0004,1180 => 0.0008,889 => 0.0002,837 => 0.0008,623 => 0.0004,456 => 0.0006,979 => 0.0004,1203 => 0.0018,262 => 0.0016,92 => 0.0012,338 => 0.0008,1205 => 0.0012,1068 => 0.0012,767 => 0.0012,124 => 0.0004,267 => 0.0006,360 => 0.0014,85 => 0.001,940 => 0.0004,25 => 0.0096,798 => 0.0006,181 => 0.0012,1028 => 0.001,894 => 0.0012,768 => 0.0004,1217 => 0.0006,1071 => 0.0008,1185 => 0.0014,356 => 0.0006,458 => 0.0004,1163 => 0.002,194 => 0.0008,1002 => 0.001,52 => 0.0004,233 => 0.0006,234 => 0.0002,367 => 0.0002,758 => 0.0008,278 => 0.0006,1222 => 0.0008,959 => 0.0006,1142 => 0.0014,336 => 0.0004,533 => 0.001,64 => 0.0016,568 => 0.0026,408 => 0.0004,651 => 0.0008,220 => 0.001,444 => 0.0008,943 => 0.0006,257 => 0.0002,993 => 0.0016,524 => 0.0006,932 => 0.0008,588 => 0.0008,854 => 0.0004,67 => 0.0024,864 => 0.0004,229 => 0.0006,190 => 0.0002,228 => 0.0006,1165 => 0.0008,179 => 0.0006,395 => 0.0006,537 => 0.0006,325 => 0.001,437 => 0.0004,536 => 0.0006,615 => 0.0008,878 => 0.0002,402 => 0.0006,340 => 0.0004,526 => 0.0008,989 => 0.0008,519 => 0.0008,1202 => 0.0016,807 => 0.0006,174 => 0.0008,319 => 0.0002,371 => 0.0006,1221 => 0.0006,1138 => 0.0028,24 => 0.0114,156 => 0.0006,116 => 0.0006,1036 => 0.0008,1046 => 0.0012,1176 => 0.0004,496 => 0.0004,983 => 0.0004,349 => 0.0002,1196 => 0.001,56 => 0.0004,839 => 0.0008,633 => 0.0002,1113 => 0.0006,520 => 0.0014,895 => 0.0006,1249 => 0.0004,491 => 0.0008,158 => 0.001,708 => 0.0002,160 => 0.0014,464 => 0.0004,582 => 0.0012,478 => 0.0004,1103 => 0.0008,992 => 0.0006,384 => 0.0012,1047 => 0.0008,490 => 0.0006,946 => 0.001,479 => 0.0012,335 => 0.0006,828 => 0.0006,114 => 0.0006,165 => 0.001,133 => 0.0004,748 => 0.0006,328 => 0.0008,1122 => 0.001,84 => 0.001,977 => 0.001,752 => 0.0004,645 => 0.001,93 => 0.0006,425 => 0.0004,564 => 0.0008,1208 => 0.001,608 => 0.0006,1175 => 0.001,77 => 0.0004,311 => 0.0004,1061 => 0.0008,605 => 0.0002,441 => 0.0004,132 => 0.0004,516 => 0.0004,550 => 0.0008,231 => 0.0008,302 => 0.0006,1178 => 0.0012,225 => 0.0008,1087 => 0.001,76 => 0.001,224 => 0.0002,213 => 0.0006,204 => 0.0008,122 => 0.0006,769 => 0.0006,414 => 0.0008,287 => 0.001,939 => 0.0008,180 => 0.0006,102 => 0.001,1130 => 0.0012,413 => 0.001,601 => 0.0004,561 => 0.0004,806 => 0.0006,731 => 0.0004,1258 => 0.0002,877 => 0.0004,331 => 0.0004,948 => 0.001,985 => 0.0008,638 => 0.0008,1237 => 0.0006,1234 => 0.0002,462 => 0.001,239 => 0.0008,969 => 0.0004,1184 => 0.0012,1133 => 0.0008,296 => 0.0002,139 => 0.0004,1210 => 0.0008,717 => 0.0002,1145 => 0.0008,705 => 0.0006,212 => 0.001,310 => 0.0004,871 => 0.0012,1272 => 0.0002,760 => 0.0004,265 => 0.0004,282 => 0.0006,1214 => 0.0018,853 => 0.001,
# 17 => 0.0004,
# 801 => 0.001,250 => 0.0006,466 => 0.0004,934 => 0.0006,127 => 0.0006,475 => 0.0004,1013 => 0.0002,1193 => 0.002,851 => 0.0004,637 => 0.0004,1063 => 0.001,1172 => 0.0014,744 => 0.0002,1022 => 0.0002,226 => 0.0014,43 => 0.0028,203 => 0.0012,1033 => 0.0014,1137 => 0.0014,104 => 0.0006,960 => 0.001,999 => 0.0006,604 => 0.0004,468 => 0.0012,320 => 0.0002,1236 => 0.0002,919 => 0.0006,465 => 0.0006,998 => 0.0008,857 => 0.0012,48 => 0.0028,1045 => 0.0008,702 => 0.0006,711 => 0.0002,737 => 0.0006,1086 => 0.0016,422 => 0.001,1225 => 0.0002,196 => 0.0008,576 => 0.0012,968 => 0.0008,281 => 0.001,578 => 0.0006,277 => 0.0006,255 => 0.0002,485 => 0.0002,405 => 0.001,746 => 0.0008,301 => 0.0012,164 => 0.0002,1190 => 0.001,830 => 0.001,1006 => 0.001,925 => 0.0006,136 => 0.0004,151 => 0.0004,1057 => 0.0018,342 => 0.0004,900 => 0.0004,611 => 0.0012,1197 => 0.0018,741 => 0.0002,283 => 0.0006,159 => 0.0004,448 => 0.0008,926 => 0.0006,459 => 0.0004,1011 => 0.0012,696 => 0.0002,538 => 0.001,121 => 0.0008,109 => 0.0008,833 => 0.0008,298 => 0.0004,1001 => 0.0006,457 => 0.0004,1171 => 0.001,722 => 0.0006,836 => 0.0002,1238 => 0.0004,168 => 0.0008,644 => 0.001,906 => 0.0004,784 => 0.0002,1162 => 0.0008,636 => 0.0008,211 => 0.0008,359 => 0.0004,777 => 0.0004,332 => 0.0008,299 => 0.0002,363 => 0.0004,1207 => 0.0006,198 => 0.0008,1206 => 0.0016,1037 => 0.0004,482 => 0.0002,469 => 0.0004,887 => 0.0004,571 => 0.0012,1088 => 0.001,955 => 0.0008,1010 => 0.0006,374 => 0.001,505 => 0.0008,600 => 0.0012,827 => 0.0004,689 => 0.0002,920 => 0.0004,449 => 0.0006,480 => 0.0008,879 => 0.0006,369 => 0.001,1020 => 0.0012,1021 => 0.0006,850 => 0.0006,990 => 0.001,1069 => 0.0016,1235 => 0.0002,1095 => 0.0004,698 => 0.0004,1070 => 0.0008,486 => 0.0004,1040 => 0.0006,530 => 0.0008,170 => 0.001,1066 => 0.0008,1270 => 0.0002,42 => 0.0028,193 => 0.0004,59 => 0.0002,675 => 0.0006,1183 => 0.0018,796 => 0.0004,527 => 0.0002,811 => 0.0004,726 => 0.0002,1139 => 0.0026,865 => 0.0004,388 => 0.0006,69 => 0.0004,991 => 0.001,219 => 0.0004,223 => 0.0002,802 => 0.0008,351 => 0.0004,572 => 0.0006,434 => 0.0006,259 => 0.0004,1099 => 0.0006,997 => 0.0002,1244 => 0.0002,558 => 0.0012,460 => 0.0008,263 => 0.0012,357 => 0.001,1096 => 0.0014,915 => 0.0008,665 => 0.0006,206 => 0.001,927 => 0.0014,32 => 0.001,316 => 0.001,385 => 0.001,809 => 0.0006,670 => 0.0004,923 => 0.0012,432 => 0.0006,381 => 0.0008,719 => 0.0002,1009 => 0.002,781 => 0.0006,1125 => 0.001,1081 => 0.0008,804 => 0.0004,404 => 0.0006,910 => 0.0004,691 => 0.001,928 => 0.0012,812 => 0.0008,1025 => 0.001,632 => 0.0006,1140 => 0.002,1012 => 0.0004,618 => 0.0004,341 => 0.0004,321 => 0.0002,1110 => 0.0018,420 => 0.0012,186 => 0.0004,1035 => 0.0016,1042 => 0.0012,856 => 0.0012,1038 => 0.001,322 => 0.0006,218 => 0.002)

# Test Summary:           | Pass  Total
# mincut file - 200 nodes |    1      1

# real    1m49.458s
# user    1m49.725s
# sys     0m0.564s
