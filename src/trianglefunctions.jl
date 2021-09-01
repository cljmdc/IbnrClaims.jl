"""
    taccum(x::Incremental)

Returns an accumulated triangle out of an incremental triangle `x`.
"""
function taccum(x::Incremental)
    acum = cumsum(x.claims, dims=2)
    for i in 1:size(acum, 2)
        for j in 1:size(acum, 1)
            if (i + j) > (size(acum, 1) + 1)
                acum[i, j] = 0
            end
        end
    end
    return Accumulated(acum)
end


"""
    tdeacum(x::Accumulated)

Returns an incremental triangle out of an accumulated triangle `x`.
"""
function tdeacum(x::Accumulated)
    des = zeros(eltype(x.claims), size(x.claims, 1), size(x.claims, 1))
    des[:,1] = x.claims[:,1]
    for j in 2:size(x.claims, 1)
        for i in 1:size(x.claims, 1)
            des[i, j] = x.claims[i, j] - x.claims[i, j - 1]
            if (i + j) > (size(x.claims, 1) + 1)
                des[i, j] = 0
            end
        end
    end
    return Incremental(des)
end


"""
    incurred(x::Accumulated)

Returns the diagonal of an accumulated triangle `x`.
"""
function incurred(x::Accumulated)
    incurred = []
    for i in 1:size(x.claims, 1)
        push!(incurred, x.claims[i, size(x.claims,1)-i+1])
    end
    return incurred
end


"""
    randtri(n, d)

Returns a `n`x`n` random matrix, whose values are randomly
taken from the distribution `d`.
"""
function randtri(n::Int, d)
    r = zeros(Float64, n, n)
    for i in 1:n
        for j in 1:(n - i + 1)
            r[i,j] = round(rand(d); digits=3)
        end
    end
    return r
end


# Auxiliary function. Helps checking no claims under the diagonal.
function siniestros_bajo_diagonal(t::Matrix)
    q = []
    for i in 1:size(t, 1)
        for j in (size(t, 1)-i+2):(size(t, 2))
            push!(q, t[i,j])
        end
    end
    sum(abs.(q)) != 0
end


# Auxiliary function. Helps calculating loss ratio vector.
function suma_movil_vector(x::Vector, per::Int)
    smv = []
    for i in 1:(length(x)-per+1)
        push!(smv, sum(getindex(x, i:(i+per-1))))
    end
    return smv
end