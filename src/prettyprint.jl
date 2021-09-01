
## Overloading of Base.show function to pretty print triangles.

Base.show(io::IO, ::MIME"text/plain", z::Accumulated{T}) where{T} =
begin
    println(io, "Accumulated Triangle {$T}:")
    Base.print_matrix(IOContext(stdout, :compact => true, :limit => true), z.claims)
end

Base.show(io::IO, ::MIME"text/plain", z::AccumulatedCompleted{T}) where{T} =
begin
    println(io, "Accumulated Completed Triangle {$T}:")
    Base.print_matrix(IOContext(stdout, :compact => true, :limit => true), z.claims)
end

Base.show(io::IO, ::MIME"text/plain", z::Incremental{T}) where{T} =
begin
    println(io, "Incremental Triangle {$T}:")
    Base.print_matrix(IOContext(stdout, :compact => true, :limit => true), z.claims)
end

Base.show(io::IO, ::MIME"text/plain", z::IncrementalCompleted{T}) where{T} =
begin
    println(io, "Incremental Completed Triangle {$T}:")
    Base.print_matrix(IOContext(stdout, :compact => true, :limit => true), z.claims)
end