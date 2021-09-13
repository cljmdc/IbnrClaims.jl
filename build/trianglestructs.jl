
abstract type Triangle{T <: Real} end

struct Incremental{T} <: Triangle{T}
    claims::Matrix{T}
    function Incremental(claims::Matrix{T}) where T <: Real
        if size(claims)[1] != size(claims)[2]
            error("The number of rows and the number of columns must be the same.")
        elseif siniestros_bajo_diagonal(claims::Matrix{T})
            error("Having claims under the diagonal is not supported.")
        end
        new{T}(claims)
    end
end

struct Accumulated{T} <: Triangle{T}
    claims::Matrix{T}
    function Accumulated(claims::Matrix{T}) where T <: Real
        if size(claims)[1] != size(claims)[2]
            error("The number of rows and the number of columns must be the same.")
        elseif siniestros_bajo_diagonal(claims::Matrix{T})
            error("NHaving claims under the diagonal is not supported.")
        end
        new{T}(claims)
    end
end

struct IncrementalCompleted{T} <: Triangle{T}
    claims::Matrix{T}
    function IncrementalCompleted(claims::Matrix{T}) where T <: Real
        if size(claims)[1] != size(claims)[2]
            error("The number of rows and the number of columns must be the same.")
        end
        new{T}(claims)
    end
end

struct AccumulatedCompleted{T} <: Triangle{T}
    claims::Matrix{T}
    function AccumulatedCompleted(claims::Matrix{T}) where T <: Real
        if size(claims)[1] != size(claims)[2]
            error("The number of rows and the number of columns must be the same.")
        end
        new{T}(claims)
    end
end
