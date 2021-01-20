using Test

include("./ann.jl")

@testset "initialisation" begin
  layer_dims = [5, 4, 3]
  parms = init_ann_model(layer_dims; seed=70)


  @test size(parms["w1"]) == (layer_dims[2], layer_dims[1])
  @test parms["w1"] ≈ Float32[ 0.318851   0.439791   0.244843   0.56474   0.0140048;
                               0.401535   0.0771849  0.0814277  0.517576  0.399674;
                               0.431036   0.224612   0.225044   0.627921  0.224198;
                               0.0359117  0.136611   0.598639   0.107276  0.503642 ]

  @test size(parms["w2"]) == (layer_dims[3], layer_dims[2])
  @test parms["w2"] ≈ Float32[ 0.356487  0.0401505  0.251124  0.0910389;
                               0.44893   0.491702   0.152735  0.251607;
                               0.481913  0.0862954  0.273743  0.669299 ]

  @test size(parms["b1"]) == (layer_dims[2], 1)
  @test parms["b1"] ≈ Float32[0.0; 0.0; 0.0; 0.0]

  @test size(parms["b2"]) == (layer_dims[3], 1)
  @test parms["b2"] ≈ Float32[0.0; 0.0; 0.0]
end


@testset "linear_forward/1" begin
  layer_dims = [5, 4, 3]
  parms = init_ann_model(layer_dims; seed=70)

  #  a = rand(StableRNG(70), 5, 3) # 5×3 Array{Float64,2}:
  a = Float32[ 0.504148   0.12204   0.355826  0.169619;
               0.634883   0.355143  0.946531  0.0221436;
               0.681527   0.216     0.892933  0.631941;
               0.0567814  0.387131  0.81836   0.354488;
               0.695371   0.128749  0.99283   0.796328 ]

  ntuple = linear_forward(a, parms["w1"], parms["b1"])

  @test ntuple.Z ≈ Float32[ 0.6486370122518279 0.4684193579545567 1.2244259200618004 0.4298942893299693;
                            0.6142427156005378 0.345830853464519 1.1090164767443147 0.6230209312692055;
                            0.7048368914340891 0.4529353799487677 1.3033807987823727 0.6214253140936883;
                            0.8691348484806378 0.28857839682833275 1.2644504265250152 0.8265127739276116 ]
end


@testset "linear_forward/2" begin
  x = Float32[ 1.62434536 -0.61175641;
               -0.52817175 -1.07296862;
               0.86540763 -2.3015387 ]

  w = Float32[ 1.74481176 -0.7612069  0.3190391 ]
  b = Float32[ -0.24937038 ]

  z, linear_cache = linear_forward(x, w, b)

  @test z ≈ Float32[ 3.26295337 -1.23429987 ]
end


@testset "linear_forward_sigmoid/1" begin
  x = Float32[-0.41675785 -0.05626683;
              -2.1361961  1.64027081;
              -1.79343559 -0.84174737 ]
  w = Float32[ 0.50288142 -1.24528809 -1.05795222 ]
  b = Float32[ -0.90900761 ]

  a, _linear_activ_cache = linear_forward_activation(x, w, b; activation_fn=sigmoid_afn)

  @test a ≈ Float32[ 0.96890023 0.11013289 ]
end


@testset "linear_forward_sigmoid / 2" begin
  layer_dims = [5, 4, 3]
  parms = init_ann_model(layer_dims; seed=70)

  #  a = rand(StableRNG(70), 5, 3) # 5×3 Array{Float64,2}:
  a = Float32[ 0.504148   0.12204   0.355826  0.169619;
               0.634883   0.355143  0.946531  0.0221436;
               0.681527   0.216     0.892933  0.631941;
               0.0567814  0.387131  0.81836   0.354488;
               0.695371   0.128749  0.99283   0.796328 ]


  ntuple = linear_forward_activation(a, parms["w1"], parms["b1"]; activation_fn=sigmoid_afn)

  @test size(ntuple[1]) == (4, 4)
  @test ntuple[1] ≈ Float32[0.656703  0.61501   0.772841  0.605848;
                            0.648908  0.585606  0.751946  0.650905;
                            0.669259  0.611337  0.786403  0.650543;
                            0.704566  0.571648  0.779791  0.695617 ]

end


@testset "linear_forward_relu/1" begin
  x = Float32[-0.41675785 -0.05626683;
              -2.1361961  1.64027081;
              -1.79343559 -0.84174737 ]
  w = Float32[ 0.50288142 -1.24528809 -1.05795222 ]
  b = Float32[ -0.90900761 ]

  a, _linear_activ_cache = linear_forward_activation(x, w, b; activation_fn=relu_afn)

  @test a ≈ Float32[ 3.43896131 0.0 ]
end


@testset "linear_forward_relu /2" begin
  layer_dims = [5, 4, 3]
  parms = init_ann_model(layer_dims; seed=70)

  #  a = rand(StableRNG(70), 5, 3) # 5×3 Array{Float64,2}:
  a = Float32[ 0.504148   0.12204   0.355826  0.169619;
               0.634883   0.355143  0.946531  0.0221436;
               0.681527   0.216     0.892933  0.631941;
               0.0567814  0.387131  0.81836   0.354488;
               0.695371   0.128749  0.99283   0.796328 ]


  ntuple = linear_forward_activation(a, parms["w1"], parms["b1"]; activation_fn=relu_afn)

  @test size(ntuple[1]) == (4, 4)
  @test ntuple[1] ≈ Float32[ 0.648637  0.468419  1.22443  0.429894;
                             0.614242  0.345831  1.10902  0.623021;
                             0.704837  0.452935  1.30338  0.621426;
                             0.869134  0.288578  1.26445  0.826513 ]

end


@testset "forward_pass" begin
  parms = Dict("w1" => Float32[ 0.35480861  1.81259031 -1.3564758 -0.46363197  0.82465384;
                                -1.17643148  1.56448966  0.71270509 -0.1810066  0.53419953;
                                -0.58661296 -1.48185327  0.85724762  0.94309899 0.11444143;
                                -0.02195668 -2.12714455 -0.83440747 -0.46550831 0.23371059 ],
               "b1" => Float32[ 1.38503523;
                                -0.51962709;
                                -0.78015214;
                                0.95560959 ],
               "w2" => Float32[-0.12673638 -1.36861282 1.21848065 -0.85750144;
                               -0.56147088 -1.0335199  0.35877096 1.07368134;
                               -0.37550472  0.39636757 -0.47144628 2.33660781 ],
               "b2" => Float32[ 1.50278553;
                                -0.59545972;
                                0.52834106 ],
               "w3" => Float32[ 0.9398248 0.42628539 -0.75815703 ],
               "b3" => Float32[ -0.16236698 ])

  x = Float32[ -0.31178367  0.72900392  0.21782079 -0.8990918;
               -2.48678065  0.91325152  1.12706373 -1.51409323;
               1.63929108 -0.4298936  2.63128056  0.60182225;
               -0.33588161  1.23773784  0.11112817  0.12915125;
               0.07612761 -0.15512816  0.63422534  0.810655 ]

  al, caches = forward_pass(x, parms)

  @test length(caches) == 3
  @test al ≈ Float32[ 0.03921668 0.70498921 0.19734387 0.04728177 ]
end


@testset "cost_fn" begin
  y = Float32[1.  1. 1.]
  ŷ = Float32[0.8 0.9  0.4]

  @test cost_fn(ŷ, y) ≈ 0.41493159961539694
end


@testset "linear_backward" begin
  ∂z = Float32[ 1.62434536 -0.61175641 ]
  linear_cache = (
                  Float32[-0.52817175 -1.07296862;
                          0.86540763 -2.3015387;
                          1.74481176 -0.7612069 ],
                  Float32[ 0.3190391  -0.24937038  1.46210794 ],
                  Float32[ -2.06014071 ]
                  )

  (∂w, ∂b, ∂aₚ) = linear_backward(∂z, linear_cache)

  @test ∂aₚ ≈ Float32[ 0.51822968 -0.19517421;
                       -0.40506361  0.15255393;
                       2.37496825 -0.89445391 ]

  @test ∂w ≈ Float32[ -0.10076895  1.40685096  1.64992505 ]
  @test ∂b ≈ Float32[ 0.50629448 ]
end


@testset "linear_backward_activation / sigmoid" begin
  ∂a = Float32[-0.41675785 -0.05626683]

  linear_activ_cache = (
                        (Float32[ -2.1361961 1.64027081;
                                 -1.79343559 -0.84174737;
                                 0.50288142 -1.24528809 ],
                         Float32[ -1.05795222 -0.90900761 0.55145404 ],
                         Float32[ 2.29220801 ]),
                        Float32[ 0.04153939 -1.11792545 ],
                        )

  (∂w, ∂b, ∂aₚ) = linear_backward_activation(∂a , linear_activ_cache; activation_fn=sigmoid_afn)

  @test ∂aₚ ≈ Float32[ 0.11017994  0.01105339;
                       0.09466817  0.00949723;
                       -0.05743092 -0.00576154 ]
  @test ∂w ≈ Float32[ 0.10266786  0.09778551 -0.01968084 ]
  @test ∂b ≈ Float32[ -0.05729622 ]
end


@testset "linear_backward_activation / relu" begin
  ∂a = Float32[-0.41675785 -0.05626683]

  linear_activ_cache = (
                        (Float32[ -2.1361961 1.64027081;
                                 -1.79343559 -0.84174737;
                                 0.50288142 -1.24528809 ],
                         Float32[ -1.05795222 -0.90900761 0.55145404 ],
                         Float32[ 2.29220801 ]),
                        Float32[ 0.04153939 -1.11792545 ],
                        )

  (∂w, ∂b, ∂aₚ) = linear_backward_activation(∂a , linear_activ_cache; activation_fn=relu_afn)

  @test ∂aₚ ≈ Float32[ 0.44090989  0.0;
                       0.37883606  0.0;
                       -0.2298228   0.0]
  @test ∂w ≈ Float32[ 0.44513824  0.37371418 -0.10478989 ]
  @test ∂b ≈ Float32[ -0.20837892 ]
end


@testset "backward_pass" begin
  ŷ = Float32[ 1.78862847 0.43650985 ]
  y = [1, 0]
  meta_cache = (
            (
             (Float32[ 0.09649747 -1.8634927;
                     -0.2773882 -0.35475898;
                     -0.08274148 -0.62700068;
                       -0.04381817 -0.47721803],
              Float32[-1.31386475  0.88462238  0.88131804 1.70957306;
                      0.05003364 -0.40467741 -0.54535995 -1.54647732;
                      0.98236743 -1.10106763 -1.18504653 -0.2056499 ],
              Float32[ 1.48614836;
                       0.23671627;
                       -1.02378514]
             ),
             Float32[ -0.7129932  0.62524497;
                      -0.16051336 -0.76883635;
                      -0.23003072  0.74505627 ]
            ),

            (
             (Float32[ 1.97611078 -1.24412333;
                       -0.62641691 -0.80376609;
                       -2.41908317 -0.92379202 ],
              Float32[ -1.02387576 1.12397796 -0.13191423 ],
              Float32[ -1.62328545 ]
             ),
             Float32[ 0.64667545 -0.35627076 ]
             )
           )

  ∇ = backward_pass(ŷ, y, meta_cache)

  @test ∇["∂w1"] ≈ Float32[ 0.41010002  0.07807203  0.13798444  0.10502167;
                            0.0         0.0         0.0         0.0      ;
                            0.05283652  0.01005865  0.01777766  0.0135308 ]

  @test ∇["∂b1"] ≈ Float32[-0.22007063;
                           0.0;
                           -0.02835349 ]
  @test ∇["∂a1"] ≈ Float32[ 0.12913162 -0.44014127;
                            -0.14175655  0.48317296;
                            0.01663708 -0.05670698 ]
end


@testset "update_ann_model" begin
  parms = Dict(
               "w1" => Float32[-0.41675785 -0.05626683 -2.1361961  1.64027081;
                               -1.79343559 -0.84174737  0.50288142 -1.24528809;
                               -1.05795222 -0.90900761  0.55145404  2.29220801 ],
               "b1" => Float32[ 0.04153939;
                                -1.11792545;
                                0.53905832 ],
               "w2" => Float32[ -0.5961597 -0.0191305 1.17500122 ],
               "b2" => Float32[ -0.74787095 ])

  ∇ = Dict("∂w1" => Float32[ 1.78862847  0.43650985  0.09649747 -1.8634927;
                             -0.2773882 -0.35475898 -0.08274148 -0.62700068;
                             -0.04381817 -0.47721803 -1.31386475  0.88462238 ],
           "∂b1" => Float32[0.88131804;
                            1.70957306;
                            0.05003364 ],
           "∂w2" => Float32[ -0.40467741 -0.54535995 -1.54647732 ],
           "∂b2" => Float32[ 0.98236743 ])

  parms = update_ann_model(parms, ∇; η=0.1)

  @test parms["w1"] ≈ Float32[-0.59562069 -0.09991781 -2.14584584  1.82662008;
                              -1.76569676 -0.80627147  0.51115557 -1.18258802;
                              -1.0535704  -0.86128581  0.68284052  2.20374577]
  @test parms["b1"] ≈ Float32[ -0.04659241;
                               -1.28888275;
                               0.53405496 ]
  @test parms["w2"] ≈ Float32[ -0.55569196  0.0354055   1.32964895 ]
  @test parms["b2"] ≈ Float32[ -0.84610769 ]
end
