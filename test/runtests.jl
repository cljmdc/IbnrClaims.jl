using IbnrClaims
using Test

@testset "IbnrClaims.jl" begin
    si = [1996 463 157 158 232 115; 2762 289 456 273 407 0; 2898 163 432 283 0 0; 2930 315 217 0 0 0; 2474 395 0 0 0 0; 2684 0 0 0 0 0]
    sa = [1996 2459 2616 2774 3006 3121; 2762 3051 3507 3780 4187 0; 2898 3061 3493 3776 0 0; 2930 3245 3462 0 0 0; 2474 2869 0 0 0 0; 2684 0 0 0 0 0]
    pr = [3095,5640,5416,5069,4657,5352]
    lr = [0.85,0.85,0.85,0.85,0.85,0.85]
    
    ti = Incremental(si)
    ta = Accumulated(sa)

    @test ibnrcl(ta) ≈ 3885.51761789107
    @test ibnrbf(ta, pr, lr) ≈ 4128.66896034168

    @test ti.claims == tdeacum(ta).claims
    @test ta.claims == taccum(ti).claims
    @test ti.claims == tdeacum(taccum(ti)).claims
    @test ta.claims == taccum(tdeacum(ta)).claims
    @test incurred(ta) == [3121, 4187, 3776, 3462, 2869, 2684]
    
    @test tfactors(ti) ≈ [1.1244257274, 1.1068043331, 1.0742512479, 1.09749771132, 1.03825681969, 1.0]
    @test tfactors(ta) ≈ [1.1244257274, 1.1068043331, 1.0742512479, 1.09749771132, 1.03825681969, 1.0]
    
end
