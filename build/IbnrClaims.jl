module IbnrClaims

export Triangle,
Incremental,
Accumulated,
IncrementalCompleted,
AccumulatedCompleted,
taccum,
tdeacum,
tfactors,
fillcl,
ibnrcl,
tquotas,
expositionbf,
fillbf,
ibnrbf,
randtri,
lossesbf,
incurred,
lossratiosbf

using Distributions

include("trianglestructs.jl")
include("trianglefunctions.jl")
include("prettyprint.jl")
include("chainladder.jl")
include("bornhuetterferguson.jl")

end