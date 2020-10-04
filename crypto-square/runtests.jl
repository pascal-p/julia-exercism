using Test

include("crypto_square.jl")

@testset "ciphering..." begin
  # @test cipher_text(value) == expected
  @test cipher_text("") == ""
  @test cipher_text("A") == "a"
  @test cipher_text("  b ") == "b"
  @test cipher_text("  @1,%! ") == "1"
  @test cipher_text("This is fun!") == "tsf hiu isn"    
  @test cipher_text("Chill out.") == "clu hlt io "

  @test cipher_text("ZOMG! ZOMBIES!!!") == "zzi ooe mms gb "
  @test cipher_text("Never vex thine heart with idle woes") == "neewl exhie vtetw ehaho ririe vntds"

  
  @test cipher_text("If man was meant to stay on the ground, nature would have given us roots.") == "imtgtdes fearuhn  mayorau  anouevs  ntnnwer  wttdogo  aohnuio  ssealvt "

  src_exp = [
            ("The whole problem with the world is that fools and fanatics are always so certain of themselves, and wiser people so full of doubts.",
             "tbwfaaneeo hlootyosof eeroisfapd wmllcstnlo hwdssohdeu oiiaacewsb ltsnremiot ehtderssfs pthfateeu  rhaalalrl  oetnwivpl "),
            ("Men are born ignorant, not stupid. They are made stupid by education.",
             "mrnpruu entiepc nindmia agotadt rnthdbi eoseeyo brtysen oauatd "
            ),
            ("The fact that an opinion has been widely held is no evidence whatever that it is not utterly absurd; indeed in view of the silliness of the majority of mankind, a widely spread belief is more likely to be foolish than sensible.",
             "tpivrtesmialie hiditeeiandis  enedhrdljdbkh  filealiloaeet  aoyntynirwllh  cnhciavniiiya  theetbietdetn  talwisesyefos  hsdhsuwsolibe  abianroofysen  testodffmsmfs  aenetittapooi  nnovunhhnrrob  oweetdeekeell "),
            ("It Has Been Said That Man Is A Rational Animal. All My Life I Have Been Searching For Evidence Which Could Support This.",
             "iailmehdcr tisaybieot hdanlennut atriiegclh shamfnfedi bataesowss etilierhu  emoahaeip  nanlarvcp  snalvciho ")
        ]

  for (src, exp) in src_exp
    @test cipher_text(src) == exp
  end
end

# decriphering
