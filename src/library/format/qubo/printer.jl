function write_model(io::IO, model::AbstractModel{V,T,U}, fmt::QUBO) where {V,T,U}
    data = Dict{Symbol,Any}(
        :linear_terms    => Dict{Int,T}(variable(model, i) => v for (i, v) in linear_terms(model)),
        :quadratic_terms => Dict{Tuple{Int,Int},T}((variable(model, i), variable(model, j)) => v for ((i, j), v) in quadratic_terms(model)),
        :linear_size     => linear_size(model),
        :quadratic_size  => quadratic_size(model),
        :scale           => scale(model),
        :offset          => offset(model),
        :metadata        => metadata(model),
        :dimension       => dimension(model),
    )

    _print_metadata(io, data, fmt, Val(fmt.style))
    _print_header(io, data, fmt, Val(fmt.style))
    _print_entries(io, data, fmt, Val(fmt.style))

    return nothing
end

function _print_header(::IO, ::Dict{Symbol,Any}, ::QUBO, ::Val{_}) where {_}
    return nothing
end

function _print_header(io::IO, data::Dict{Symbol,Any}, ::QUBO, ::Val{:dwave})
    dimension      = data[:dimension]
    linear_size    = data[:linear_size]
    quadratic_size = data[:quadratic_size]

    println(io, "p qubo 0 $(dimension) $(linear_size) $(quadratic_size)")

    return nothing
end

function _print_header(io::IO, data::Dict{Symbol,Any}, ::QUBO, ::Val{:mqlib})
    dimension      = data[:dimension]
    linear_size    = data[:linear_size]
    quadratic_size = data[:quadratic_size]

    println(io, "$(dimension) $(linear_size + quadratic_size)")

    return nothing
end

function _print_metadata(::IO, ::Dict{Symbol,Any}, ::QUBO, ::Val{_}) where {_}
    return nothing
end

function _print_metadata_entry(
    io::IO,
    key::AbstractString,
    val::Any,
    ::QUBO,
    ::Val{:dwave},
)
    println(io, "c $(key) : $(val)")

    return nothing
end

function _print_metadata_entry(io::IO, key::AbstractString, val::Any, ::QUBO, ::Val{:mqlib})
    println(io, "# $(key) : $(val)")

    return nothing
end

function _print_metadata(
    io::IO,
    data::Dict{Symbol,Any},
    fmt::QUBO,
    style::Union{Val{:dwave},Val{:mqlib}},
)
    scale    = data[:scale]
    offset   = data[:offset]
    metadata = data[:metadata]

    !isnothing(scale) && _print_metadata_entry(io, "scale", scale, fmt, style)
    !isnothing(offset) && _print_metadata_entry(io, "offset", offset, fmt, style)

    if !isnothing(metadata)
        for (key, val) in metadata
            _print_metadata_entry(io, key, JSON.json(val), fmt, style)
        end
    end

    return nothing
end

function _print_entries(io::IO, data::Dict{Symbol,Any}, ::QUBO, ::Val{_}) where {_}
    for (i, l) in data[:linear_terms]
        println(io, "$(i) $(i) $(l)")
    end

    for ((i, j), q) in data[:quadratic_terms]
        println(io, "$(i) $(j) $(q)")
    end

    return nothing
end

function _print_entries(io::IO, data::Dict{Symbol,Any}, ::QUBO, ::Val{:dwave})
    println(io, "c linear terms")

    for (i, l) in data[:linear_terms]
        println(io, "$(i) $(i) $(l)")
    end

    println(io, "c quadratic terms")

    for ((i, j), q) in data[:quadratic_terms]
        println(io, "$(i) $(j) $(q)")
    end

    return nothing
end

function _print_entries(io::IO, data::Dict{Symbol,Any}, ::QUBO, ::Val{:mqlib})
    println(io, "# linear terms")

    for (i, l) in data[:linear_terms]
        println(io, "$(i) $(i) $(l)")
    end

    println(io, "# quadratic terms")

    for ((i, j), q) in data[:quadratic_terms]
        # NOTE: in MQLib qubo files, quadratic coefficients
        # are halved when written to the file
        println(io, "$(i) $(j) $(q/2)")
    end

    return nothing
end

