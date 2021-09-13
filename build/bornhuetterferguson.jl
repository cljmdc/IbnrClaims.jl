
"""
    tquotas(x::Union{Accumulated, Incremental}

Returns a vector containing the quotas development
for the incremental or accumulated triangle `x`.

# Example
```
julia> ti = Incremental([3 5 2; 4 2 0; 1 0 0])
Incremental Triangle {Int64}:
 3  5  2
 4  2  0
 1  0  0

julia> tquotas(ti)
3-element Vector{Float64}:
 0.4
 0.8
 1.0

 julia> ta = Accumulated([3 8 10; 4 6 0; 1 0 0])
Accumulated Triangle {Int64}:
 3  8  10
 4  6   0
 1  0   0

julia> tquotas(ta)
3-element Vector{Float64}:
 0.4
 0.8
 1.0
```
"""
function tquotas(x::Union{Accumulated, Incremental})
    return reverse(1 ./ cumprod(reverse(tfactors(x))))
end


"""
    expositionbf(primes::Vector, lossratios::Vector)

Returns a vector containing the estimated losses when
having a vector of `primes` and a vector of `lossratios`.

# Example
```
julia> primes = [15, 7, 3];

julia> lossratios = [0.85, 0.7, 0.79];

julia> expositionbf(primes, lossratios)
3-element Vector{Float64}:
 12.75
  4.8999999999999995
  2.37
```
"""
function expositionbf(primes::Vector, lossratios::Vector)
    return primes .* lossratios
end


"""
    fillbf(x::Accumulated, primes::Vector, lossratios::Vector)

Returns an accumulated completed triangle, containing both the known accumulated claims
and the Bornhuetter-Ferguson accumulated estimates, when having a `primes` vector and
a `lossratios` vector.

# Example
```
julia> ta = Accumulated([3 8 10; 4 6 0; 1 0 0])
Accumulated Triangle {Int64}:
 3  8  10
 4  6   0
 1  0   0

julia> primes = [15, 7, 3];

julia> lossratios = [0.85, 0.7, 0.79];

julia> fillbf(ta, primes, lossratios)
Accumulated Completed Triangle {Float64}:
 3.0  8.0    10.0
 4.0  6.0     6.98
 1.0  1.948   2.422
```
"""
function fillbf(x::Accumulated, primes::Vector, lossratios::Vector)
    cuo = tquotas(x)
    exposicion = expositionbf(primes, lossratios)
    matriz_completa = convert(Matrix{Float64}, deepcopy(x.claims))
    for i in 1:size(matriz_completa, 2)
        for j in 1:size(matriz_completa, 1)
            if (i + j) > (size(matriz_completa, 1) + 1)
                matriz_completa[i, j] = matriz_completa[i,size(matriz_completa, 2)+1-i] + (cuo[j] - cuo[size(matriz_completa, 2)+1-i]) * exposicion[i]
            end
        end
    end
    return AccumulatedCompleted(matriz_completa)
end


"""
    fillbf(x::Incremental, primes::Vector, lossratios::Vector)

Returns an incremental completed triangle, containing both the known incremental claims
and the Bornhuetter-Ferguson incremental estimates, when having a `primes` vector and
a `lossratios` vector. 

# Example
```
julia> ti = Incremental([3 5 2; 4 2 0; 1 0 0])
Incremental Triangle {Int64}:
 3  5  2
 4  2  0
 1  0  0

julia> primes = [15, 7, 3];

julia> lossratios = [0.85, 0.7, 0.79];

julia> fillbf(ti, primes, lossratios)
Incremental Completed Triangle {Float64}:
 3.0  5.0    2.0
 4.0  2.0    0.98
 1.0  0.948  0.474
```
"""
function fillbf(x::Incremental, primes::Vector, lossratios::Vector)
    y = taccum(x)
    z = fillbf(y, primes, lossratios)
    des = zeros(Float64, size(z.claims, 1), size(z.claims, 1))
    des[:,1] = z.claims[:,1]
    for j in 2:size(z.claims, 1)
        for i in 1:size(z.claims, 1)
            des[i, j] = z.claims[i, j] - z.claims[i, j - 1]
        end
    end
    return IncrementalCompleted(des)
end


"""
    ibnrbf(x::Accumulated, primes::Vector, lossratios::Vector)

Returns the estimated incurred but not reported reserve under the Bornhuetter-Ferguson
methodology, for an accumulated triangle `x`, a `primes` vector and a `lossratios` vector.

# Example
```
julia> ta = Accumulated([3 8 10; 4 6 0; 1 0 0])
Accumulated Triangle {Int64}:
 3  8  10
 4  6   0
 1  0   0

julia> primes = [15, 7, 3];

julia> lossratios = [0.85, 0.7, 0.79];

julia> ibnrbf(ta, primes, lossratios)
2.4019999999999992
```
"""
function ibnrbf(x::Accumulated, primes::Vector, lossratios::Vector)
    tri_completado = fillbf(x, primes, lossratios)
    ib = 0
    for i in 1:size(tri_completado.claims, 2)
        j = (tri_completado.claims[i,end] - tri_completado.claims[i, end - i + 1])
        ib = ib + j
    end
    return ib
end


"""
    ibnrbf(x::Incremental, primes::Vector, lossratios::Vector)

Returns the estimated incurred but not reported reserve under the Bornhuetter-Ferguson
methodology, for an incremental triangle `x`, a `primes` vector and a `lossratios` vector.

# Example
```
julia> ti = Incremental([3 5 2; 4 2 0; 1 0 0])
Incremental Triangle {Int64}:
 3  5  2
 4  2  0
 1  0  0

julia> primes = [15, 7, 3];

julia> lossratios = [0.85, 0.7, 0.79];

julia> ibnrbf(ti, primes, lossratios)
2.4019999999999992
```
"""
function ibnrbf(x::Incremental, primes::Vector, lossratios::Vector)
    return ibnrbf(taccum(x), primes, lossratios)
end


"""
    lossratiosbf(x::Accumulated, primes::Vector, periods::Int)

Returns a vector of loss ratios, obtained from an accumulated triangle `x` and
a `primes` vector.
The loss ratios are obtained by summing over the last `periods` number of
incurred claims and primes.

# Example
```
julia> ta = Accumulated([3 8 10; 4 6 0; 1 0 0])
Accumulated Triangle {Int64}:
 3  8  10
 4  6   0
 1  0   0

julia> primes = [15, 7, 3];

julia> periods = 2;

julia> lossratiosbf(ta, primes, periods)
3-element Vector{Float64}:
 0.7272727272727273
 0.7272727272727273
 0.7
```
"""
function lossratiosbf(x::Accumulated, primes::Vector, periods::Int)
    xi = incurred(x)
    tmp = suma_movil_vector(xi, periods)./suma_movil_vector(primes, periods)
    lrbf= zeros(Float64, length(xi) - length(tmp))
    fill!(lrbf, tmp[1])
    return vcat(lrbf, tmp)
end
