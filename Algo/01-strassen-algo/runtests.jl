using Test

include("strassen_algo.jl")

@testset "basic 2×2 matrix mult" begin
  X = [1 2; 3 4]
  Y = [3 1; 4 1]

  Z = [11  3; 25  7]

  @test strassen_fn(X, Y) == Z
end


@testset "basic 3×3 matrix mult with augmentation" begin
  X = [ 4   4  5
        2   0  3
        -4  -4  1]
  Y = [ 1  -4   2
        0  -1  -5
        1  -5  -1]

  Z = [ 9  -45  -17
        5  -23    1
        -3   15   11
       ]

  @test strassen_fn(X, Y) == Z
end

@testset "basic 5×5 matrix mult with augmentation" begin
  X = [ 3   5  -1  4  5;
        0   2  -1  1  5;
        2   4   4  1  0;
        -1  -1   0  3  2;
        0   3   1  5  4 ]

  Y = [0  0   3   2  1;
       -1  3   0   5  5;
       -1  2   2   3  5;
       0  4  -1  -1  2;
       5  5   5   5  0
       ]

  Z = [ 21  54  28  49  31
        24  33  22  31   7
        -8  24  13  35  44
        11  19   4   0   0
        16  51  17  33  30 ]

  @test strassen_fn(X, Y) == Z
end


@testset "basic 4×4 matrix mult" begin
  X = [10 20 13 40; 11  2  4 15; 20 35 45 60; 15 20 30 40]
  Y = [10 40 13 10; 2  11 15 12; 20 25 10 11; 12 20 45 32]

  Z = [
       880  1745  2360  1763
       374   862   888   658
       1890  3510  3935  3035
       1270  2370  2595  2000
       ]

  @test strassen_fn(X, Y) == Z
end


@testset "16×16 matrix mult" begin
  X =  [
        35  33  35  45  30  33  49  48  34  12   5  14  43  16  24  31;
        26  31  37  34   8  12  13  34  22  49  37  36  36  22  36  27;
        12  16  43  31  34  30  50  49   9  49  19  18  35  33  23  32;
        33  34   9  10  49  12  24  25  31  23  45  38  19  35  50  11;
        2  45   4  18  42  26  32  26  31   9  29   8  32  39  43   2;
        29  10  32  23  11   3  10  21   2   2  39  23  12  30  12  18;
        16  26  27  19   4  22  19  17  13  36  48  31  22  46   5  17;
        11   2   9  19   4  15  20  50   2   7   6  31  23   3  49  48;
        14  37   8  23   5  20  34  33  29   6   8   1  14   1  48  45;
        23  44  31  34  40  28  26  40  47  19  41  21  32   5   6  24;
        39  16  35  39   8  20  14  14  42   4  33  29  28  38  26  13;
        31  10  44  41   6  20  45  13  34  12   5   4  27   8  41   6;
        50  24  17  18  17  11  19  14   1   3  42  29  29  45  40  37;
        46  38  46  34  20   4   3   8  20  30  26  46  17  49  44  20;
        31  28  49  37   1  18  17  26   9   1   3  40  22  48  15  29;
        4   2  36  36  48  19  41  29  29   6  36  12  17   1  12  12
        ]

  Y = [
       51  58  28  65  46  49  58  13  72  58  56  75  67  69  71  77;
       57  22  15  17  72  41  62  33  66  30  11  17  32  75  59  11;
       58  56  47  38  43  19  26  57  36  14  31  66  58  68  69  45;
       18  67  33  75  61  44  37  21  29  52  28  28  64  73  73  48;
       26  44  16  33  70  66  65  70  55  40  36  53  71  65  75  57
       43  24  25  13  70  66  30  56  33  36  40  48  40  65  47  29
       43  49  64  64  22  29  63  67  42  75  42  28  13  47  40  62
       64  74  41  38  45  38  27  12  25  77  67  17  25  17  16  72
       15  44  50  48  40  50  77  12  52  23  76  59  47  31  76  74
       73  70  66  51  51  25  68  41  41  39  76  71  22  57  28  49
       31  40  64  48  38  73  42  10  12  68  58  48  13  12  19  40
       75  67  21  59  22  33  17  46  51  29  67  66  17  69  28  19
       51  61  37  69  54  50  61  49  28  23  70  64  37  24  77  57
       41  38  65  54  53  49  42  11  61  63  22  58  37  68  58  22
       37  66  68  59  51  13  23  43  27  46  16  29  58  70  22  57
       70  72  69  33  38  28  76  72  19  27  10  48  20  33  62  74
       ]

  Z = [
       22382  26317  20522  23500  23926  20057  24059  19432  19711  21543  21122  22004  19958  25356  26757  25989
       23024  25975  21239  22859  21858  18049  21459  16492  17736  19645  21292  22662  17102  23780  22207  22477
       23916  26828  22613  23100  23234  19179  23147  20290  18397  22091  21436  22820  17827  24850  23790  24528
       20158  23207  19715  21651  21694  19581  21460  16055  19217  20708  19978  21551  17669  23820  21493  21689
       16056  18606  16898  17885  20277  17497  18988  14358  16153  17969  15937  16536  15375  20335  19634  18025
       13164  15124  12640  14013  12682  11949  11942   9158  10875  13188  11692  13835  10793  14336  13875  13336
       18180  18911  17327  17664  17320  16084  17194  12554  14749  16719  16899  18755  12222  18886  17588  15957
       15869  18777  14444  14817  13287  10376  12732  12701   9710  13756  12432  12647  10550  14375  12841  16731
       15142  17806  15522  14901  15797  12107  16537  13207  12098  14523  12113  12682  12335  16403  16145  17963
       20690  23693  18769  20895  22845  20884  23398  17150  18483  19688  21504  21483  17935  22600  24691  23366
       17177  20936  17618  20476  18850  17264  18262  12811  16567  17220  17846  20247  16745  21266  21780  19589
       14707  19033  16065  18396  16385  13024  16349  13553  13859  15061  14971  16337  15497  19234  19162  18969
       18961  21225  18306  20046  18689  16839  18435  14225  16262  18551  15596  19587  15450  21155  20016  19330
       21775  24418  19878  22669  21859  17706  20384  15659  19981  18779  18476  23316  19075  26767  23601  20579
       18856  20380  15935  18410  17684  14434  16029  13784  16015  15826  14551  18311  15049  21679  20447  17087
       13819  18098  14818  16384  16106  15274  16304  14175  12361  15607  15599  15542  13919  16490  17878  18266
  ]

  @test strassen_fn(X, Y) == Z

end

@testset "32×32 matrix mult" begin
  X =  [
    44   25  -49  -32  -42  -13  -26   32   32  -26    7   21  -20   37   24  -46   28   35  -20   -2  -28   36  -14   42   46   35   42   -2   -4  -41   18   42;
 -22  -21   21  -48  -18    3   48  -45   11   41   20  -34  -50   47   12  -12   13  -31  -29   12   20  -49   39  -40   40  -47   27    5  -13    5   31  -31;
  49   42  -33   -8  -13  -36   10   28  -25  -41  -29  -14   35  -50  -25  -50  -11   39   31   28  -44   14   37  -48  -13  -49   25  -19   44   36   20  -25;
  27  -34    5   17  -46  -25   36   40  -17  -41  -47   18    6   15   -3   -1   27  -36   10   29   19  -46    5  -47    9  -12    6  -20   28   -5   41  -15;
  46  -44   -2    8   -1  -45   27   12   -3   38   24  -16   -9  -19   -3   40  -44   21  -18  -36   17   36   38   25  -28   31  -42    7  -29    8   45   -2;
  36  -15   47   40  -48  -25  -38  -36  -40  -22  -22   29  -11  -47   46   21  -31   24  -26   22   -4   22   25  -20  -17   -4   41   27  -29   26   17   15;
  47   -3   15    8   16    9   47   12  -42  -35  -35   50   34  -42   31  -11   44   -7   50  -14  -40   33   46    2    6   38   10   39   29   30    9  -48;
  14   33    7   34   -4   49   39  -38  -50   12   33   41   29   20    8  -40   -4    5  -13   -6  -31  -37   14  -22   12  -22   -9  -28  -16   -4   29   32;
 -21  -15  -34  -48    2    5   22   23  -28    5  -18   -4    3   29    2  -48  -12   44   -8  -22  -20  -35  -11   43  -45    5   48  -34  -32  -38   18   22;
   8  -42   18   -2  -44    3   36  -30   24  -23  -21  -38    8   23   11   -6  -28   37   45   -5  -32  -19  -39  -17   35  -47   -4  -14    7   50   26   25;
 -42   -3   33    6   11   50  -34   30   13  -33  -30   43  -30    5   -5   37   -8    2  -13  -34  -25   46   15  -18   15   44   11   46   23   18    2  -13;
  26  -35  -40   33   33   32   20  -23   -2    8  -25   -5  -27   22  -29   13  -25  -17  -43   25  -38   -9  -24   45  -21   32   11  -24   49  -22   45  -23;
  -8   44   -8   27   20  -23  -13  -42  -39   34   15  -22  -45   38  -34    9  -39   24  -28   -5   25    0  -32  -46   -5  -38   -4   35   37   37   17  -44;
 -12   -3   50  -13  -31  -46   -5  -42   12    7   15   -5   47  -18  -27  -31   26  -35  -27   27   41   14  -35   12    4   -6   47  -34  -24  -41  -50  -41;
  37   27   24   10  -27   -6    6   13  -40  -49   16   35  -17    4    4   14   22   14   30  -13  -44   19    8  -33   -6   -5  -21   47   11  -22   -9   15;
   1    6  -17  -36   45  -40  -34    3  -30  -34  -20   32  -42   44  -26   13  -49  -38    2  -16  -32   46  -33   46   -9   21  -43   -6   36  -21   10  -27;
  24   -5  -31  -14   27    2   -7  -20   45   39  -42   30   38   10   40    6   -5   23   37  -42    1    4  -42  -48    3  -14  -13   43   27  -50   33  -32;
  45    7   35   24   46  -14   14   11   12   33   47   -4   19  -30  -39   40   29   10  -21   28   41  -26  -40   10   24  -44  -39   43   -9   16   -8  -17;
 -40  -26   11  -26  -25   -5    7  -26  -31   21  -25  -34  -28    1   -1  -32   36   15   44   -3   23  -30  -30   45   43  -17   38   36   11   -2   38   22;
 -38  -16  -37   19  -36  -29  -17  -19  -19   22   14  -19   19   21  -46  -14   21  -45  -26   45  -36   -5   20  -11   24  -26   -6    3  -10  -23   21    6;
  14  -16  -19    0  -18   15   -6   50   49   20   40   -6   28  -42   -5  -45  -27   48   42    8   -3  -19   17   36   11  -24    8  -36  -10  -39   -3  -49;
  48   35   12   41  -23  -24  -48   44   50   28   22  -34    6   49   12  -37  -34   19   -4   46  -49   35  -43  -41  -23  -11   41   -2  -48  -28   24   24;
 -10   39  -38   25  -46   48   34  -21   16   42   30  -24   42   41   35   -2   -2  -27   13  -28   -9  -45   15   48   27   24  -41   34   24   26   31   13;
  48   10   19    5  -19   38   27   20  -16   48    8    2    7   44   20   24   26   11  -16    2  -26  -26  -10   -5  -43   10  -19  -38   44   -4   50   29;
  21  -33  -17   38   26  -40    7   46  -39  -27   24  -26   -2  -38   24   21    8  -20   15   26  -32   33   47  -28  -25   -2  -37   -2   36  -13   11  -37;
  31   18  -30   -5    0   -3  -14  -37   -8   14   28   40   -4  -27   23   16  -19  -13   41  -14   50  -38   47   -8   42   12  -18    6   20   14  -41   13;
  -7  -28  -16   24    7  -21  -35  -22  -14   -7   41   17    1  -35  -34  -16   -6  -31  -18  -14   28  -12  -33   22   -4   34  -40   48  -19   24  -19  -49;
 -40   45   23  -13  -44   47  -43   50  -10  -15   25  -25   50  -39   26  -38   29   38    8   -5   20   25  -24    6   27  -23  -29   16   44   38  -46  -36;
 -39   13   -9  -45  -35   23   20   36   -6   43  -49  -23   35  -11   22   27   31  -40   48    6   26  -48   45   -2  -42  -44  -38   31   17  -29   -3  -50;
 -15   -9    0  -23   33  -19    1  -25   14  -38   47  -49   -8   43   11    7   33   18   43  -30  -12  -41   27   45   -1  -39  -15   21   27  -45   -8  -49;
  48  -50   33   15   47   24    2  -30   22    3   49  -15   24   22  -45   45  -42  -38  -16   25    3   28  -24  -36   12    7   25   25  -12   37   -1    7;
  -19   -5   -2  -41  -47   38   10   -3    3  -29  -22   27  -49  -12   30   16   10    4  -45   30   36    1  -20   18   27  -35    0   34   45   15  -41   6
  ]

  Y = [
  -8   48   24   45    5  -48   32  -46   -1   50    8   45   -4   39   -1  -34  -31  -48  -12  -12   -1  -20   42  -21   16  -13   15   31   -1   30  -40  -28;
 -34  -45  -31  -29   -7   30    9   14   46  -50    7   -2  -13  -36   50    5   27   18   31   30    6   -6  -19   31   29   -7  -12  -16   -5  -18   16  -33;
 -40   44   28   44   -7  -33    3   49   32  -32   -2  -36  -49   -3  -47   26   13  -31  -30    3   -5  -25  -44    5   15   34  -20  -17  -41   -5   39  -16;
  24  -17  -20   16    6   -8    6   28   -8   35  -19   35  -41  -33  -43   39   28   48   42   -6   30   11   10    2   23    5    7  -48  -20   50   48   15;
   3  -27   47  -17  -41  -48  -15   26   27    7  -12   13  -36   30   35  -49  -19   10   34  -22  -22  -40   39   18  -27  -30   -4    1    5   10  -35   27;
  30  -17   38  -45  -49  -23  -22    3  -32    7   21    2  -35   17   16   42   11    0  -32  -45   -5  -38   -2   41  -48   35   30    2  -37   31  -24   14;
  11  -48   12   14   17    2  -33   40   -7  -47  -39   12   46    0  -21   20   42   -7  -32   -4  -26   50   -1   -3   -7  -44   40  -34   -2   44    9   40;
  -1   30    2   16   -8   34   10   39  -38   20   11   18   29  -24   -2  -36    6  -13  -50  -43   15  -29  -33  -37  -46   21   17   31  -50   25  -32   20;
   2  -13   42  -36   19   23  -12  -16  -43    4  -39  -33   13  -36   44   -3   24  -36  -19   45   38   29    0   34   -1   -6  -33   32  -38  -12    9  -20;
 -34  -42   47  -26  -22   49   24  -39  -20  -16  -30  -39  -28  -24   -5   41   17   25   -6    4   50  -25   16   41  -10   36   25   37  -31  -17   50  -14;
  -9    4  -22   49    1  -32   32   33  -50  -18  -46   27  -50   39   -9   21   25   43  -18    0   10   48  -46  -43   47   50   23   46   20  -13   10   12;
 -33  -42    9   -3   -4  -36   23    8  -12  -11   26   14   30  -38    5  -40   11  -21  -11  -19  -26  -15  -23   38   20  -45  -23   31   23  -10   44  -24;
  12   -5   17   16  -41    5    0   37  -34   14   13   14  -33  -14   -7  -39   -8   29   17   16  -33   -7  -15  -40  -28   40  -19  -33  -33   13   -4   24;
  35    7   32   36   33   18  -15  -27  -48   38  -22   49   -7   30    3   -8  -43   46   30    5    2  -49    8  -45  -10  -26   13  -42  -42   45   -4  -32;
  28  -47   43   -2   21   10   -3  -35  -17   34   25   11   47  -14  -32   34  -40  -34  -33   -4  -41  -13   49  -22  -13   -9    4  -27   32   -3    0   50;
 -46  -47   10  -26   36  -20   23   40    3    8   45   12  -35  -12   50   -3  -13  -31   27  -26  -15  -12  -32   44  -36   18  -16  -20   17  -48   11  -45;
  47   19  -28  -42   34  -28   13  -25  -11   14    8   28  -27   48   33   42   36  -13  -18  -40  -38   -5   31   21    4  -22   11   38   14   29  -42   18;
  -9   20   37   22    8  -21  -47   17   28  -38  -25   43    1  -50   -4   21   35  -30  -20   41  -16   41   20  -31   31  -11  -10   27  -25   26  -23  -41;
 -15    8   41   19  -43   24   12  -17   -8  -41   39   -2  -29  -45   -9  -48  -31   38   16  -46  -13  -16  -33  -41   40  -30   28   23    2  -48   43    2;
  38   13  -41  -47    7   10   -6   23    0   29   10   -4  -45  -34   43   20   28  -17  -35   17   23  -31  -25   12  -41   48  -48  -43    9   25  -17   47;
 -12  -50   11  -44   14  -20   48   16   34  -13  -36    5  -10   23   39  -29   16   47   -2   41   26   -7    7  -34   36   23  -39  -50  -25   -4  -28   45;
  19   43  -50   26    8   18  -38  -36   47   -1   18   19   40   39   21   50  -38  -34    6   -1  -24   25   33  -17   47   13    7   49  -19  -31   23   40;
  45  -11   39   50   -2   15  -12  -24  -21    3  -43  -23    0   11    8   15  -14    4   34   29   40   20   33  -46   31  -33   35  -38   35    5  -46   50;
 -42  -23   -4    9   -3  -34   24   -9    0  -28   25   47   -8   31    7  -19    2  -22  -46  -19  -12    2   32   26    4  -38   33   13  -15   30  -37  -44;
 -14   35   11   17   24   32  -40  -24  -23  -31    0   34  -46   48   -5  -29  -32   -4   40   25   34   46   40  -20  -43  -39  -27   43  -36  -29   33   13;
 -15   30   40   43  -48  -31  -21   22  -39  -11   -8   12  -29  -44    5   -6   -7   14  -21  -34   20   47   22  -32  -42  -25   24    2   31   42   34   31;
  41   44  -18   44  -35   17  -31   48    8   13  -26   17   -5    5   -6   44  -29   36   42  -40  -38  -21   -4   48   20   32   29  -25   26  -29   12  -13;
  14   16   36   41   48   28  -13    7   10   20  -20  -20  -11  -31   -1  -40   17   -3  -45   25   48   34  -26  -37  -43  -43   -1  -22  -23   -3   29  -33;
  14  -49  -23   16  -31   39   22  -14   47    8   43   16   16   39    5   -3   14    5   -1   -8   45  -48  -11   42   22   39   -5  -25  -37   37  -30   19;
  -9    2  -48   22    2   42  -24  -10  -44  -50   35   -8   41  -42   48   24  -29   35  -45    7  -28    8   43   45  -15   -6  -41  -17  -50  -43   21  -27;
   7   -1   15   39   46  -44   33   29    4  -15   13  -27  -48  -37   -3  -50    1  -38   28    3  -45   31  -40   -7    0   29   -5   38  -45  -36   38  -47;
  37  -47   12  -10   32   -6   45   48   34   41   21  -23   -6   48    2  -18   35   37   38   19  -27   14  -34   15  -33  -21   -6  -10   28   -3  -24  -28
  ]

  Z = [
    5560    9933    -731    6521   5797   -256  -2114  -6337   -2183   5735      76  10679    4627   6649    913   -2279  -2615  -6964    -162      46  -3054   6353   5369  -4835    453   -7797   3974  13534    1994   4229  -4891  -5780;
  5220   -1102    3683    -736   9066   5515  -2948  -4992   -5580  -3302  -12397  -7937   -1867   6213  -1484    7470   -549   1692    1680    6786   4535   1139    886    834   -483    1723    636  -4471    -975  -4585   1545   1764;
  5997    8612  -11390    7363  -5131   8684  -4875  -1915    6840  -2523    4557    382    8860  -6529    321   -2044  -1885  -3031    3257    2577  -3578   -705    178  -2683   8954    3018  -1666    204   -1243  -1953  -5617   2618;
  6195    2687   -3253    1597   5035    709   3859   2346   -2679   5958    3340    478    2622  -1989  -4216   -6115    -68  -2243    1047   -3408  -1322  -4790  -5086  -3474  -2428    1209  -2769  -7214   -1622   4736  -1431   4831;
 -7500    -419    6731   11236   5659  -6708   4192   -408   -1426  -1844   -5091   -832    2124  -2608  -2742   -3563  -1723  -6345   -2878    3162   1529  11330   3382  -9322   3414   -1568   4646   5334    -518  -1710   2204  -2669;
   855    6543   -3921    9128   5637  -4022   -140   3097    7229   4557    3386  -3063    1901  -7911  -6417    6916  -3454  -6636     596    3529  -4935   3413    220    426   4712    2893  -4998  -6402    6798  -6677   6968  -3779;
  2891    5887    2522   13248  -6304  -2245  -6214  -2950   -1012  -3246    8218   5485    4487  -4660  -3101   -2748  -6126  -7551   -5989  -11038  -7383   1376   7119  -3867   1056  -10523   6413    943    1545   3026   2322   8010;
  3738   -6453    2017    2914  -1532  -5627   1509   3843   -3424  -1228   -1939   1720   -5627   1680  -7709    2947   4445   6022    5953     545  -6055    468  -2527    175   1364    -417   3825  -2411    1469   5148   3293   -937;
  3123     594    4745    1450  -4400  -3839  -1803   3712    -921     55   -3568   2434    6132     85  -5684   -1612    598   1225    -547   -4335  -9880  -1734   -181  -1873   -860   -2830   9531   1663    4817   6286  -7987  -4643;
  1816    3738    1338    4575   5590   5546  -5333  -1527   -2630  -3856    4256  -1067    3247  -2813  -6260      87  -3066  -1307    -152    4265  -6042   3771  -1420   -590  -1328    -739  -3772   -469   -8821  -4413   4918  -7879;
  -605    4228    2910    4955  -1533   1236  -7825   2573     355   -606    5544  -1267    1732  -4712   2727    1097  -4010  -5071   -1596   -5512   1650   -124  -1258   4422  -5702   -3122   -989   1801   -4577  -2915   6498  -2385;
  1991   -2918    -671    -271  -3530  -7288   -248   -236    -265   6276    2080   5172   -2781   2864    271     -52   -268  -4327    1521   -7339   1193  -4839   3651  10381  -5606    2149   5162  -1431   -1283  11349  -2884  -2890;
 -4399   -3240   -6878     892   4027   5780   -797  -1727    8790  -4627   -4395   -719   -1793  -2769   2645    2912    380   7550    5899    7952   7488  -2545   -903   3597   6532    5545  -5523  -5677   -7596  -4137   7065  -7863;
 -2866    7909   -9561   -4574  -3955  -1295    463   1571    3127  -1724   -6983   -538   -3506   6126  -2516    7062   2089   2322     327    3299    590  -1059  -1227   1388   7889    9082  -4209  -2150    3666   -679   2059   6401;
   948    5465   -1418    8987   4764  -2419    776    677    4393   2458    5149   3668    1307    -93  -4722   -2104    892  -4808    -601   -3454  -2329   1869  -6562  -6848   3988   -6348   2829   2411    4359   1105   2227  -3404;
 -8938    1132   -4263    3434  -1384  -3158   1759  -6247    6969    108    9581   4317    5675   5034   2494  -12720  -9780  -5728    2679   -5068   -133  -5969    399    328   1022   -6878    241   5521    1178   -862    315  -5890;
 -1523   -5057   14767   -2880     10   2042     -3  -7775    1754   3569    1395  -1295    1316  -6843  -1377  -10230  -3459  -6003    3460    1239     30  -3310    605  -1935   -738   -2595  -1613   6114   -5283  -3153   6426  -3645;
 -8886   -2146    -177   -5221   5539  -5909   6731   5787    1164  -2320   -3693   2277  -12123   1846   5320   -5124   8967  -1568   -6155    4355   5466    130  -3120   2348  -2750    4194  -7654   2751   -8920    311   -453  -4205;
  1396    2147    1422     673   4205   3099    421   -845    4741  -6289    1033  -1687   -4924   3312  -4222   -1579   1426   3443    -775    -707  -2013   2069   -930    943  -1077   -3329   2058   1363   -3720  -3761   2388  -5499;
  7149    3184   -9559   -1708   5580   6025   1252  -1997   -4134   5371   -3210  -3317   -6342   4075  -1440    2247   2316   5359    8084    3773   5480   2410  -4168  -1319  -2809    4156   -444   -891    2276   -232   2107   1552;
 -3168    4790    5135    1225  -8574   1166   -688  -1963   -7695  -4521   -5938   2727   -1607  -5422  -4474   -2027   2642  -3078   -5582     412   4986   2605   -954  -6715   6442    5512   4612  10855   -4145   1861  -3428   3315;
  5321   13843   -1060    5607   2933   5166  -1013   1425   -2870  11184   -5488   -239   -3933  -7848  -4114    4587  -1267   -466    3535    3831   1229  -2183  -6065  -5224   1253   10390   -866   5208   -4985   -155   6762  -6995;
   367  -13439    7618    2490   2187   6409   3401  -4134  -13136  -3405     105   1258   -5252  -2277   -751   -1112   2435   8279   -2410    2555   5439   5479   1063  -2048  -6534   -3453   5921  -4067   -8024   4552   4696  -3437;
  1507   -7086    5006    1099    694  -4846   7918   1478   -3261   4716    4372   2216   -3503    678  -1961    3692   4379  -2814   -2683   -5785  -4217  -8169  -3755   4642  -2781    7132   5249    351   -4921   9015  -2840  -5405;
  5074    3278   -5224    6839   -273   -537   1301  -1192     769   6560    3147   2444    1909    633  -3480    -204  -2906  -5118    -408   -5546   1836     -2    740  -9356   2739    3303   3877   -520    5188   3214  -4366  13570;
 -5004  -10328    5885    -880  -2843   1305   6056  -5758   -1722  -3086     355    640   -1636   1760   3150   -6363  -2345   6873    3673    3399   7337   1581   3925  -2401   3935   -6535  -1581  -2197    7097  -5007    270   3705;
 -7985    3096   -4986     510  -1194  -4966   3081  -1339   -3721  -2487   -2368    275   -2822  -2130    -60   -5393   1226   4119   -6627     561   6874   6286   1140  -3147    252   -1282  -3205   2555     954   -260   5187    242;
 -1650    3596   -8055   -3503  -5878  10065  -3550  -2577     287  -7587    6368   2750    1937  -1254   1560    6341   3145   1317  -12330    2345   3197  -1442   -108  -2981   1616    9449  -4929   2977  -12048   -132  -3081   6238;
    16  -10993    6706  -11350  -1307  10018   5425  -4895   -2422  -1178    2975  -9530    2062  -6661   2063   -3041   2837  -1120   -6217   -1824   5347  -9882  -5956  -1639  -4042    2919   3209  -7668   -2313   -893  -4967   5960;
   834    -320    6092    3857   2260  -2811     -6  -4987   -1255  -1820   -4573   5639   -4785   8447  -1923   -4427  -1576   -118    1044    -135   1752   -589    574  -8541   6790   -5702   6191    -88    1394   3088  -8829  -1326;
   332    6775    1251    6307  -1048  -4518  -1648   6567   -4642   5335   -3174   -207  -10429   5151   3107    -804  -5126   3832    2625    -570   1512   -798  -3002   1711  -5783    8170  -4011  -2174   -4950  -3815   5644  -1418;
  1158   -5697   -6355   -9732   7267   4651  -1409  -3323    5251    286    5309    701    9858   5726   5278    5278   3731  -6878  -11067    3205   3038  -2429   1017   9076  -4247    -708  -6514  -4321   -1156    683  -6220    696
  ]

  @test strassen_fn(X, Y) == Z
end

# julia> @time strassen_fn(X, Y)
#   0.000740 seconds (18.00 k allocations: 1.423 MiB)
# 16×16 Array{Int64,2}:
#  22382  26317  20522  23500  23926  20057  24059  19432  19711  21543  21122  22004  19958  25356  26757  25989
#  23024  25975  21239  22859  21858  18049  21459  16492  17736  19645  21292  22662  17102  23780  22207  22477
#  23916  26828  22613  23100  23234  19179  23147  20290  18397  22091  21436  22820  17827  24850  23790  24528
#  20158  23207  19715  21651  21694  19581  21460  16055  19217  20708  19978  21551  17669  23820  21493  21689
#  16056  18606  16898  17885  20277  17497  18988  14358  16153  17969  15937  16536  15375  20335  19634  18025
#  13164  15124  12640  14013  12682  11949  11942   9158  10875  13188  11692  13835  10793  14336  13875  13336
#  18180  18911  17327  17664  17320  16084  17194  12554  14749  16719  16899  18755  12222  18886  17588  15957
#  15869  18777  14444  14817  13287  10376  12732  12701   9710  13756  12432  12647  10550  14375  12841  16731
#  15142  17806  15522  14901  15797  12107  16537  13207  12098  14523  12113  12682  12335  16403  16145  17963
#  20690  23693  18769  20895  22845  20884  23398  17150  18483  19688  21504  21483  17935  22600  24691  23366
#  17177  20936  17618  20476  18850  17264  18262  12811  16567  17220  17846  20247  16745  21266  21780  19589
#  14707  19033  16065  18396  16385  13024  16349  13553  13859  15061  14971  16337  15497  19234  19162  18969
#  18961  21225  18306  20046  18689  16839  18435  14225  16262  18551  15596  19587  15450  21155  20016  19330
#  21775  24418  19878  22669  21859  17706  20384  15659  19981  18779  18476  23316  19075  26767  23601  20579
#  18856  20380  15935  18410  17684  14434  16029  13784  16015  15826  14551  18311  15049  21679  20447  17087
#  13819  18098  14818  16384  16106  15274  16304  14175  12361  15607  15599  15542  13919  16490  17878  18266

# julia> @time naive_dot_prod(X, Y)
#   0.019889 seconds (28.33 k allocations: 1.495 MiB)
# 16×16 Array{Int64,2}:
#  22382  26317  20522  23500  23926  20057  24059  19432  19711  21543  21122  22004  19958  25356  26757  25989
#  23024  25975  21239  22859  21858  18049  21459  16492  17736  19645  21292  22662  17102  23780  22207  22477
#  23916  26828  22613  23100  23234  19179  23147  20290  18397  22091  21436  22820  17827  24850  23790  24528
#  20158  23207  19715  21651  21694  19581  21460  16055  19217  20708  19978  21551  17669  23820  21493  21689
#  16056  18606  16898  17885  20277  17497  18988  14358  16153  17969  15937  16536  15375  20335  19634  18025
#  13164  15124  12640  14013  12682  11949  11942   9158  10875  13188  11692  13835  10793  14336  13875  13336
#  18180  18911  17327  17664  17320  16084  17194  12554  14749  16719  16899  18755  12222  18886  17588  15957
#  15869  18777  14444  14817  13287  10376  12732  12701   9710  13756  12432  12647  10550  14375  12841  16731
#  15142  17806  15522  14901  15797  12107  16537  13207  12098  14523  12113  12682  12335  16403  16145  17963
#  20690  23693  18769  20895  22845  20884  23398  17150  18483  19688  21504  21483  17935  22600  24691  23366
#  17177  20936  17618  20476  18850  17264  18262  12811  16567  17220  17846  20247  16745  21266  21780  19589
#  14707  19033  16065  18396  16385  13024  16349  13553  13859  15061  14971  16337  15497  19234  19162  18969
#  18961  21225  18306  20046  18689  16839  18435  14225  16262  18551  15596  19587  15450  21155  20016  19330
#  21775  24418  19878  22669  21859  17706  20384  15659  19981  18779  18476  23316  19075  26767  23601  20579
#  18856  20380  15935  18410  17684  14434  16029  13784  16015  15826  14551  18311  15049  21679  20447  17087
#  13819  18098  14818  16384  16106  15274  16304  14175  12361  15607  15599  15542  13919  16490  17878  18266
