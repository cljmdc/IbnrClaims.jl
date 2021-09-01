"""
    tfactors(x::Incremental)

Returns a vector containing the incremental development factors of 
the accumulated triangle built out of the incremental triangle `x`.

# Example
```
julia> ti = Incremental([3 5 2; 4 2 0; 1 0 0])
Incremental Triangle {Int64}:
 3  5  2
 4  2  0
 1  0  0

julia> tfactors(ti)
3-element Vector{Float64}:
 2.0
 1.25
 1.0
```
"""
function tfactors(x::Incremental)
    tmp = taccum(x)
    tfactors = ones(Float64, size(x.claims)[2])
    for i in 1:(size(tmp.claims)[2] - 1)
        tfactors[i] = sum(tmp.claims[:,i + 1]) / sum(tmp.claims[1:(end - i), i])
    end
    return tfactors
end


"""
    tfactors(x::Accumulated)

Returns a vector containing the incremental development factors of the accumulated triangle `x`.

# Example
````
julia> ta = Accumulated([3 8 10; 4 6 0; 1 0 0])
Accumulated Triangle {Int64}:
 3  8  10
 4  6   0
 1  0   0

julia> tfactors(ta)
3-element Vector{Float64}:
 2.0
 1.25
 1.0
```
"""
function tfactors(x::Accumulated)
    tfactors = ones(Float64, size(x.claims)[2])
    for i in 1:(size(x.claims)[2] - 1)
        tfactors[i] = sum(x.claims[:,i + 1]) / sum(x.claims[1:(end - i), i])
    end
    return tfactors
end


"""
    fillcl(x::Accumulated)

Returns a completed accumulated triangle, which contains both the
known accumulated claims of accumulated triangle `x` and the chain ladder 
estimated accumulated claims.

# Example
```
julia> ta = Accumulated([3 8 10; 4 6 0; 1 0 0])
Accumulated Triangle {Int64}:
 3  8  10
 4  6   0
 1  0   0

julia> fillcl(ta)
Accumulated Completed Triangle {Float64}:
 3.0  8.0  10.0
 4.0  6.0   7.5
 1.0  2.0   2.5
```
"""
function fillcl(x::Accumulated)
    factores = tfactors(x)
    matriz_completa = convert(Matrix{Float64}, deepcopy(x.claims))
    for i in 1:size(matriz_completa, 2)
        for j in 1:size(matriz_completa, 1)
            if (i + j) > (size(matriz_completa, 1) + 1)
                matriz_completa[i, j] = matriz_completa[i, j - 1] * factores[j - 1]
            end
        end
    end
    return AccumulatedCompleted(matriz_completa)
end


"""
    fillcl(x::Incremental)

Returns a completed incremental triangle, which contains both the
known incremental claims of incremental triangle `x` and the chain ladder
estimated incremental claims.

# Example
```
julia> ti = Incremental([3 5 2; 4 2 0; 1 0 0])
Incremental Triangle {Int64}:
 3  5  2
 4  2  0
 1  0  0

julia> fillcl(ti)
Incremental Completed Triangle {Float64}:
 3.0  5.0  2.0
 4.0  2.0  1.5
 1.0  1.0  0.5
```
"""
function fillcl(x::Incremental)
    factores = tfactors(x)
    tri_acum = taccum(x)
    matriz_completa = convert(Matrix{Float64}, deepcopy(tri_acum.claims))
    for i in 1:size(matriz_completa, 2)
        for j in 1:size(matriz_completa, 1)
            if (i + j) > (size(matriz_completa, 1) + 1)
                matriz_completa[i, j] = matriz_completa[i, j - 1] * factores[j - 1]
            end
        end
    end
    des = zeros(Float64, size(matriz_completa, 1), size(matriz_completa, 1))
    des[:,1] = matriz_completa[:,1]
    for j in 2:size(matriz_completa, 1)
        for i in 1:size(matriz_completa, 1)
            des[i, j] = matriz_completa[i, j] - matriz_completa[i, j - 1]
        end
    end
    return IncrementalCompleted(des)
end


"""
    ibnrcl(x::Accumulated)

Returns the estimated incurred but not reported claim reserve for the
accumulated triangle `x` using the chain ladder methodology.

# Example
```
julia> ta = Accumulated([3 8 10; 4 6 0; 1 0 0])
Accumulated Triangle {Int64}:
 3  8  10
 4  6   0
 1  0   0

julia> ibnrcl(ta)
3.0
```
"""
function ibnrcl(x::Accumulated)
    tri_completado = fillcl(x)
    ib = 0
    for i in 1:size(tri_completado.claims, 2)
        j = (tri_completado.claims[i,end] - tri_completado.claims[i, end - i + 1])
        ib = ib + j
    end 
    return ib
end


"""
    ibnrcl(x::Incremental)
    
Returns the estimated incurred but not reported claim reserve for the
incremental triangle `x` using the chain ladder methodology.

# Example
```
julia> ti = Incremental([3 5 2; 4 2 0; 1 0 0])
Incremental Triangle {Int64}:
 3  5  2
 4  2  0
 1  0  0

julia> ibnrcl(ti)
3.0
```
"""
function ibnrcl(x::Incremental)
    y = taccum(x)
    return ibnrcl(y)
end