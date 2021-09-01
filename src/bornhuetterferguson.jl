
"""
    tquotas(x::Union{Accumulated, Incremental}

Returns a vector containing the quotas development
for the incremental or accumulated triangle `x`.
"""
function tquotas(x::Union{Accumulated, Incremental})
    return reverse(1 ./ cumprod(reverse(tfactors(x))))
end


"""
    expositionbf(primes::Vector, lossratios::Vector)

Returns a vector containing the estimated losses when
having a vector of `primes` and a vector of `lossratios`.
"""
function expositionbf(primes::Vector, lossratios::Vector)
    return primes .* lossratios
end


"""
    fillbf(x::Accumulated, primes::Vector, lossratios::Vector)

Returns an accumulated completed triangle, containing both the known accumulated claims
and the Bornhuetter-Ferguson accumulated estimates, when having a `primes` vector and
a `lossratios` vector. 
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
    fillbf(x::Incremental, primas::Vector, loss_ratios::Vector)

Returns an incremental completed triangle, containing both the known incremental claims
and the Bornhuetter-Ferguson incremental estimates, when having a `primes` vector and
a `lossratios` vector. 
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
"""
function lossratiosbf(x::Accumulated, primes::Vector, periods::Int)
    xi = incurred(x)
    tmp = suma_movil_vector(xi, periods)./suma_movil_vector(primes, periods)
    lrbf= zeros(Float64, length(xi) - length(tmp))
    fill!(lrbf, tmp[1])
    return vcat(lrbf, tmp)
end
