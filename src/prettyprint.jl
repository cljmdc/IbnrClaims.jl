
## Overloading of Base.show function to pretty print triangles.

Base.show(io::IO, ::MIME"text/plain", z::Accumulated{T}) where{T} =
begin
    println(io, "Triangle Acumulado {$T}:")
    Base.print_matrix(IOContext(stdout, :compact => true, :limit => true), z.claims)
end

Base.show(io::IO, ::MIME"text/plain", z::AccumulatedCompleted{T}) where{T} =
begin
    println(io, "Triangle Acumulado Completado {$T}:")
    Base.print_matrix(IOContext(stdout, :compact => true, :limit => true), z.claims)
end

Base.show(io::IO, ::MIME"text/plain", z::Incremental{T}) where{T} =
begin
    println(io, "Triangle Incremental {$T}:")
    Base.print_matrix(IOContext(stdout, :compact => true, :limit => true), z.claims)
end

Base.show(io::IO, ::MIME"text/plain", z::IncrementalCompleted{T}) where{T} =
begin
    println(io, "Triangle Incremental Completado {$T}:")
    Base.print_matrix(IOContext(stdout, :compact => true, :limit => true), z.claims)
end