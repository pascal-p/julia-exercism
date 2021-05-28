using Test

include("vlq.jl")

@testset "#encode - single multi-byte" begin
  @test encode([0]) == [0x00]
  @test encode([0x00]) == [0x00]
  @test encode([0x40]) == [0x40]
  @test encode([0x7f]) == [0x7f]

  @test encode([0x2000]) == [0xc0, 0x00]
  @test encode([0x3fff]) == [0xff, 0x7f]
  @test encode([0x4000]) == [0x81, 0x80, 0x00]

  @test encode([0x100000]) == [0xc0, 0x80, 0x00]
  @test encode([0x1fffff]) == [0xff, 0xff, 0x7f]
  @test encode([0x200000]) == [0x81, 0x80, 0x80, 0x00]
  @test encode([0x8000000]) == [0xc0, 0x80, 0x80, 0x00]

  @test encode([0xfffffff]) == [0xff, 0xff, 0xff, 0x7f]

  @test encode([0x10000000]) == [0x81, 0x80, 0x80, 0x80, 0x00]
  @test encode([0xff000000]) == [0x8f, 0xf8, 0x80, 0x80, 0x00]
  @test encode([0xffffffff]) == [0x8f, 0xff, 0xff, 0xff, 0x7f]
end

@testset "#encode - many multi-bytes" begin
  @test encode([0x40, 0x7f]) == [0x40, 0x7f]
  @test encode([0x4000, 0x123456]) == [
                                       0x81,
                                       0x80,
                                       0,
                                       0xc8,
                                       0xe8,
                                       0x56,
                                      ]
  @test encode([0x2000, 0x123456, 0xfffffff,
                0x00, 0x3fff, 0x4000]) == [
                                           0xc0,
                                           0x00,
                                           0xc8,
                                           0xe8,
                                           0x56,
                                           0xff,
                                           0xff,
                                           0xff,
                                           0x7f,
                                           0x00,
                                           0xff,
                                           0x7f,
                                           0x81,
                                           0x80,
                                           0x00,
                                          ];
end


@testset "#decode" begin
  @test decode([0x7f]) == UInt32[0x7f] # [0x0000007f]
  @test decode([0xc0, 0x00]) == UInt32[0x2000]
  @test decode([0xff, 0xff, 0x7f]) == UInt32[0x1fffff]

  @test decode([0x81, 0x80, 0x80, 0x00]) == UInt32[0x200000];
  @test decode([0x8f, 0xff, 0xff, 0xff, 0x7f]) == UInt32[0xffffffff]

  @test decode([0xc0,
                0x00,
                0xc8,
                0xe8,

                0x56,
                0xff,
                0xff,
                0xff,

                0x7f,
                0x00,
                0xff,
                0x7f,
                0x81,
                0x80,
                0x00]) == UInt32[0x2000, 0x123456, 0xfffffff, 0x00, 0x3fff, 0x4000]
end

@testset "#decode - exceptions" begin
  @test_throws ArgumentError decode([0xff])   # leftmost bit is 1 (and should be 0)
end
