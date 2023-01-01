using Test

include("vig-cipher_v2.jl")

@testset "encode" begin
  @test encode("HELLOWORLD", "ABCXYZ") == "HFN8BKOSN0"

  @test encode("THE QUICK BROWN FOX JUMPS OVER THE LAZY DOG", "LION") == "4PSM12WPVHP4Z41MQWAMU2023H28PZN6SMNYL7BMOWU"

  @test encode("ATTACK AT DAWN", "GO") == "G7ZOIYFOZNJO21"
end

@testset "more cases" begin
  # Vigenère
  @test encode(
    """
In 1863, Friedrich Kasiski was the first to publish a successful general attack on the Vigenere cipher. Earlier attacks relied on knowledge of the plaintext or the use of a recognizable word as a key. Kasiski's method had no such dependencies. Although Kasiski was the first to publish an account of the attack, it is clear that others had been aware of it. In 1854, Charles Babbage was goaded into breaking the Vigenere cipher when John Hall Brock Thwaites submitted a "new" cipher to the Journal of the Society of the Arts. When Babbage showed that Thwaites' cipher was essentially just another recreation of the Vigenere cipher, Thwaites presented a challenge to Babbage: given an original text (from Shakespeare's The Tempest: Act 1, Scene 2) and its enciphered version, he was to find the key words that Thwaites had used to encipher the original text. Babbage soon found the key words: "two" and "combined". Babbage then enciphered the same passage from Shakespeare using different key words and challenged Thwaites to find Babbage's key words. Babbage never explained the method that he used. Studies of Babbage's notes reveal that he had used the method later published by Kasiski and suggest that he had been using the method as early as 1846.
""" |> s -> replace(s, r"[\.,:\)\(\"\']" => "") |> uppercase |> strip, "THEQUICKBROWNFOXJUMPSOVERTHELAZYDOG"
  ) == "1UDGRD5JG8W0QWWZQTWP WCOZS3E3 H5HNL1YW9T1QJQAP7VXVWJT49UQZW9Y1PKG3AH5G4GE9CIEUA51V6MSW42ST5SBIQVPTSEFXHOX4PI7TIV3BTYDMWS8RYPO61UO473PPD52C2LS0LUTXNKJ470 YNA0T5WWNEWVSVJKAYEHQUZUMEUJNOAC2CQEOEIULZWBUORAPWVIGXPSZ0VHP1IFJO5ND7HVWMY1T5RZRT1LWKA GK20ZOD0U0K2LZNHNXNFQYLU05CXQBVD0U09L6NSHRPUKEYV47V1KNFQYLPA7VG1SPXKIGXFZKTYD91IVJP V04XN4JXLQWS8DREHVP C3CWZSPRPKF7DATVW4QSEIVMQTO1IQEHWKGCYGSJSPR98HD1FRY40LNFQYL 0UZRV LDNID5H5FEOI3TRQROQVWYQNY08OZR720R10I3 GHE0OB0ITTIBXFCNYVUV10T53R72IQ2VY2NZ9C2LS0LUT0QMJV7JMTTW21QOS5DWQEOIY 0YEPGZLD81WYOEQ73NYNFQFMXASCDT1WLPRYJD6FXZWU71KKM2BVWZ6FIUZ3AVZVQ LG2EZGL2TSVJPCPGJWZU00J51IWU4ZSBD 03ETT3FC3XXZI3CMFJBQQ3NQZ1W0QOA2UFRUIEREY4L9K6GE3TWTSHZ1WYE716CLU927D90HOPSD2D5KAGXXYHVON6SD6EOZ2TCO QZRVS9DLN2XL7YSLRS2XJOSVRV8J5ER8ZOZSU0RAGXZ 46QRFBOIP4M0JX55Z5E74JCL8Z VM XZDSA2XX6KWGX4TMPMJ6V04E74NT060U3RR4GXPXHXEOHUHKUT0QYOQT 7SRW21QO2SIDC7YH3 HJRNG6KDS8UDSOVRVOFPYJ0QOAVZRQXUGTP62USJS0LUT0CWFQ3W5XO3NTR660UWYTRI3P3YUSFCZM30HFSGWSCRS7WTY OD2BH9SHRO 15DZRXUKUXHVRXRWERXNFXTRX5RUFRUIEREGXNS4S3S7X0BLBSPWTJN NEQ6RSHT2TPRPDYGKSF5LXX8LB3IR7VUJNG1YPO 7EHZXZDZFYZDPHTNI8TVQ3F9NCR0SXUT5WS7ULVSOEO IFHRFBOIP6MVRPUN7NYSDI96Q3WCLVWGF9 9YVWY3PDQ7LB2VXU05YNFQU5OZSULRWGFPEBXX6O6ND91MBWF V QEOEIYM63BUE9S8BE6"
end

@testset "decode" begin
  @test decode("HFN8BKOSN0", "ABCXYZ") == "HELLOWORLD"

  @test decode("4PSM12WPVHP4Z41MQWAMU2023H28PZN6SMNYL7BMOWU", "LION") == "THE QUICK BROWN FOX JUMPS OVER THE LAZY DOG"
  @test decode("G7ZOIYFOZNJO21", "GO") == "ATTACK AT DAWN"
end

@testset "decode ∘ encode ≡ id" begin
  @test decode(encode("WE ARE DISCOVERED FLEE AT ONCE", "FOOBAR"), "FOOBAR") == "WE ARE DISCOVERED FLEE AT ONCE"
end

@testset "complement" begin
  @test complement("FOO", 7) == "FOOFOOFOOF"
  @test complement("FOOBAR", 4) == "FOOBARFOOB"
  @test complement("ABRACADA", 2) == "ABRACADAAB"
  @test complement("ABRACADAB", 1) == "ABRACADABA"
end
