# IbnrClaims.jl

IbnrClaims.jl is a package that works with claim development triangles.

 It calculates incurred but not reported claims reserves (IBNR).
 
 Supports chain ladder and Bornhuetter-Ferguson methods.

## Background

IbnrClaims.jl is a package that was born as an applied exercise of learning how to code, particularly in Julia. Since I have some actuarial background, it seemed natural to me to turn that knowledge into code.

The IbnrClaims.jl package does not pretend whatsoever to be a complete or extensive implementation of IBNR methods currently available.


## Overview

- Works with incremental and cumulative claims triangles.
- Performs basic operations on triangles:
  - Accumulates and deaccumulates claims.
  - Calculates claims development factors (also known as loss development factors or LDF) of triangle columns.
  - Calculates claims development quotas of triangle columns.
- Calculates the total IBNR reserve for a given triangle.
- Returns completed (known and estimated claims) claims triangles.

## Usage

### Creating a Triangle

Triangles are basically matrices that have the following restrictions:
- The number of rows and the number of columns have to be the same.
- Only zeros are allowed under the diagonal.

```julia
julia> using IbnrClaims

# creating an incremental triangle.
julia> ti = Incremental([23 15 18 11; 5 9 12 0; 7 8 0 0; 4 0 0 0])
Incremental Triangle {Int64}:
 23  15  18  11
  5   9  12   0
  7   8   0   0
  4   0   0   0

# creating an accumulated triangle.
julia> tc = Accumulated([23 38 56 67; 5 14 26 0; 7 15 0 0; 4 0 0 0])
Accumulated Triangle {Int64}:
 23  38  56  67
  5  14  26   0
  7  15   0   0
  4   0   0   0
```

```julia
# obtaining the incurred claims of an accumulated triangle.
julia> incurred(tc)
4-element Vector{Any}:
 67
 26
 15
  4
```

### Basic Operations on Triangles
```julia
# deaccumulating an Accumulated Triangle.
julia> tdeacum(tc)
Incremental Triangle {Int64}:
 23  15  18  11
  5   9  12   0
  7   8   0   0
  4   0   0   0

# accumulating an Incremental Triangle
julia> taccum(tdc)
Accumulated Triangle {Int64}:
 23  38  56  67
  5  14  26   0
  7  15   0   0
  4   0   0   0

# calculating the claim development factors from an Accumulated Triangle.
julia> tfactors(tc)
4-element Vector{Float64}:
 1.9142857142857144
 1.5769230769230769
 1.1964285714285714
 1.0

# calculating the claim development factors from an Incremental Triangle.
# the method internally accumulates the triangle and calculates the factors of the Accumulated Triangle.
julia> tfactors(ti)
4-element Vector{Float64}:
 1.9142857142857144
 1.5769230769230769
 1.1964285714285714
 1.0
```

```julia
# calculating the quotas for a given triangle.
julia> tquotas(tc)
4-element Vector{Float64}:
 0.27688278664920757
 0.5300327630141973
 0.835820895522388
 1.0

julia> tquotas(ti)
4-element Vector{Float64}:
 0.27688278664920757
 0.5300327630141973
 0.835820895522388
 1.0
```

### Chain Ladder
```julia
# calculating the IBNR reserve.
julia> ibnrcl(tc)
28.853826530612245

julia> ibnrcl(ti)
28.853826530612245
```
```julia
# completing the original IBNR triangle with the Chain Ladder estimates.
julia> fillcl(tc)
Accumulated Completed Triangle {Float64}:
 23.0  38.0      56.0     67.0
  5.0  14.0      26.0     31.1071
  7.0  15.0      23.6538  28.3001
  4.0   7.65714  12.0747  14.4465

julia> fillcl(ti)
Incremental Completed Triangle {Float64}:
 23.0  15.0      18.0      11.0
  5.0   9.0      12.0       5.10714
  7.0   8.0       8.65385   4.64629
  4.0   3.65714   4.41758   2.37182
```

### Borhnuetter-Ferguson
Unlike the Chain Ladder methodology, Bornhuetter-Ferguson methodology requires additional information: primes and loss ratios.
```julia
julia> p = [80, 40, 30, 10];

julia> lr = [0.89, 0.74, 0.82, 0.6];

# calculating the IBNR reserve.
julia> ibnrbf(tc, p, lr)
20.759598802492818

julia> ibnrbf(ti, p, lr)
20.759598802492818
```

```julia
# completing the original claims triangle with the Bornhuetter-Ferguson estimates.
julia> fillbf(tc, p, lr)
Accumulated Completed Triangle {Float64}:
 23.0  38.0     56.0      67.0
  5.0  14.0     26.0      30.8597
  7.0  15.0     22.5224   26.5612
  4.0   5.5189   7.35363   8.3387

julia> fillbf(ti, p, lr)
Incremental Completed Triangle {Float64}:
 23.0  15.0     18.0      11.0
  5.0   9.0     12.0       4.8597
  7.0   8.0      7.52239   4.03881
  4.0   1.5189   1.83473   0.985075
```