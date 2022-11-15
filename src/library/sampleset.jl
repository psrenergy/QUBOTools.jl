@doc raw"""
    Sample{T,U}(state::Vector{U}, value::T, reads::Integer) where{T,U}

""" struct Sample{T<:Real,U<:Integer}
    state::Vector{U}
    value::T
    reads::Int

    function Sample{T,U}(state::Vector{U}, value::T, reads::Integer = 1) where {T,U}
        return new{T,U}(state, value, reads)
    end
end

Sample{T}(args...) where {T} = Sample{T,Int}(args...)
Sample(args...)              = Sample{Float64}(args...)

Base.:(==)(u::Sample{T,U}, v::Sample{T,U}) where {T,U} = state(u) == state(v)
Base.:(<)(u::Sample{T,U}, v::Sample{T,U}) where {T,U}  = value(u) < value(v)

function Base.isequal(u::Sample{T,U}, v::Sample{T,U}) where {T,U}
    return isequal(reads(u), reads(v)) &&
           isequal(value(u), value(v)) &&
           isequal(state(u), state(v))
end

function Base.isless(u::Sample{T,U}, v::Sample{T,U}) where {T,U}
    if isequal(value(u), value(v))
        return isless(state(u), state(v))
    else
        return isless(value(u), value(v))
    end
end

Base.length(x::Sample)               = length(state(x))
Base.show(io::IO, s::Sample)         = join(io, ifelse.(state(s) .> 0, '↓', '↑'))
Base.getindex(s::Sample, i::Integer) = getindex(state(s), i)

@doc raw"""
    merge(u::Sample{T,U}, v::Sample{T,U}) where {T,U}

Assumes that `u == v`.
"""
function Base.merge(u::Sample{T,U}, v::Sample{T,U}) where {T,U}
    return Sample{T,U}(state(u), value(u), reads(u) + reads(v))
end

function format(
    data::Vector{Sample{T,U}},
    size::Union{Integer,Nothing} = nothing,
) where {T,U}
    if isempty(data)
        if isnothing(size)
            return (nothing, Sample{T,U}[])
        else
            return (nothing, sizehint!(Sample{T,U}[], size))
        end
    end

    bits  = nothing
    cache = sizehint!(Dict{Vector{U},Sample{T,U}}(), length(data))

    for sample::Sample{T,U} in data
        cached = get(cache, state(sample), nothing)
        merged = if isnothing(cached)
            if isnothing(bits)
                bits = length(sample)
            elseif bits != length(sample)
                sample_error("All samples must have states of equal length")
            end

            sample
        else
            if value(cached) != value(sample)
                sample_error("Samples of the same state vector must have the same energy value")
            end

            merge(cached, sample)
        end

        cache[state(merged)] = merged
    end

    data = collect(values(cache))
    data = if isnothing(size)
        sort(data)
    elseif length(data) > size
        collect(partialsort(data, 1:size))
    else
        sizehint!(sort(data), size)
    end

    return (bits, data)
end

state(s::Sample)  = s.state
value(s::Sample)  = s.value
reads(s::Sample)  = s.reads
energy(s::Sample) = value(s)

@doc raw"""
    AbstractSampleSet{T<:real,U<:Integer}

An abstract sampleset is, by definition, an ordered set of samples.
""" abstract type AbstractSampleSet{T<:Real,U<:Integer} <: AbstractVector{T} end

Base.size(ω::AbstractSampleSet) = (size(ω, 1),)

function Base.size(ω::AbstractSampleSet, axis::Integer)
    if axis == 1
        return length(ω)
    else
        return 1
    end
end

Base.firstindex(::AbstractSampleSet)            = 1
Base.firstindex(::AbstractSampleSet, ::Integer) = 1
Base.lastindex(ω::AbstractSampleSet)            = length(ω)

function Base.lastindex(ω::AbstractSampleSet, axis::Integer)
    if axis == 1
        return length(ω)
    elseif axis == 2 && !isempty(ω)
        return length(ω[begin])
    else
        return 1
    end
end

Base.iterate(ω::AbstractSampleSet) = iterate(ω, firstindex(ω))

function Base.iterate(ω::AbstractSampleSet, i::Integer)
    if 1 <= i <= length(ω)
        return (getindex(ω, i), i + 1)
    else
        return nothing
    end
end

function Base.show(io::IO, ω::S) where {S<:AbstractSampleSet}
    if isempty(ω)
        return println(io, "Empty $(S)")
    end

    println(io, "$(S) with $(length(ω)) samples:")

    for (i, s) in enumerate(ω)
        print(io, "  ")

        if i < 10
            println(io, s)
        else
            return println(io, "⋮")
        end
    end

    return nothing
end

# ~*~ :: Metadata Validation :: ~*~ #
const SAMPLESET_METADATA_PATH   = joinpath(@__DIR__, "sampleset.schema.json")
const SAMPLESET_METADATA_DATA   = JSON.parsefile(SAMPLESET_METADATA_PATH)
const SAMPLESET_METADATA_SCHEMA = JSONSchema.Schema(SAMPLESET_METADATA_DATA)

function validate(ω::AbstractSampleSet)
    report = JSONSchema.validate(SAMPLESET_METADATA_SCHEMA, metadata(ω))

    if !isnothing(report)
        @warn report
        return false
    else
        return true
    end
end

swap_domain(::D, ::D, ψ::Vector{U}) where {D<:𝔻,U<:Integer}         = ψ
swap_domain(::𝕊, ::𝔹, ψ::Vector{U}) where {U<:Integer}              = (ψ .+ 1) .÷ 2
swap_domain(::𝔹, ::𝕊, ψ::Vector{U}) where {U<:Integer}              = (2 .* ψ) .- 1
swap_domain(::D, ::D, Ψ::Vector{Vector{U}}) where {D<:𝔻,U<:Integer} = Ψ
swap_domain(::D, ::D, ω::AbstractSampleSet{T,U}) where {D<:𝔻,T,U}   = ω

function swap_domain(::A, ::B, Ψ::Vector{Vector{U}}) where {A<:𝔻,B<:𝔻,U<:Integer}
    return swap_domain.(A(), B(), Ψ)
end

function swap_domain(::A, ::B, s::Sample{T,U}) where {A<:𝔻,B<:𝔻,T,U}
    return Sample{T,U}(swap_domain(A(), B(), state(s)), energy(s), reads(s))
end

state(ω::AbstractSampleSet, i::Integer)  = state(ω[i])
reads(ω::AbstractSampleSet)              = sum(reads.(ω))
reads(ω::AbstractSampleSet, i::Integer)  = reads(ω[i])
value(ω::AbstractSampleSet, i::Integer)  = value(ω[i])
energy(ω::AbstractSampleSet, i::Integer) = value(ω, i)

@doc raw"""
    SampleSet{T,U}(
        data::Vector{Sample{T,U}},
        metadata::Dict{String, Any},
    ) where {T,U}

It compresses repeated states by adding up the `reads` field.
It was inspired by [1], with a few tweaks.

!!! info
    A `SampleSet{T,U}` was designed to be read-only.
    It is optimized to support queries over the solution set.

## References
[1] https://docs.ocean.dwavesys.com/en/stable/docs_dimod/reference/S.html#dimod.SampleSet
""" struct SampleSet{T,U} <: AbstractSampleSet{T,U}
    bits::Union{Int,Nothing}
    size::Union{Int,Nothing}
    data::Vector{Sample{T,U}}
    metadata::Dict{String,Any}

    function SampleSet{T,U}(
        bits::Union{Integer,Nothing},
        size::Union{Integer,Nothing},
        data::Vector{Sample{T,U}},
        metadata::Dict{String,Any},
    ) where {T,U}
        return new{T,U}(bits, size, data, metadata)
    end
end

function SampleSet{T,U}(
    size::Union{Integer,Nothing},
    data::Vector{Sample{T,U}},
    metadata::Union{Dict{String,Any},Nothing} = nothing,
) where {T,U}
    if !isnothing(size) && size <= 0
        throw(ArgumentError("'size' must be a positive integer or 'nothing'"))
    end

    bits, data = format(data, size)

    data = if isnothing(size)
        sort(data)
    elseif length(data) <= size
        sizehint!(sort(data), size)
    else
        collect(partialsort(data, 1:size))
    end

    if isnothing(metadata)
        metadata = Dict{String,Any}()
    end

    return SampleSet{T,U}(bits, size, data, metadata)
end

function SampleSet{T,U}(size::Union{Integer,Nothing} = nothing) where {T,U}
    return SampleSet{T,U}(size, Sample{T,U}[], Dict{String,Any}())
end

function SampleSet{T,U}(
    data::Vector{Sample{T,U}},
    metadata::Union{Dict{String,Any},Nothing} = nothing,
) where {T,U}
    return SampleSet{T,U}(nothing, data, metadata)
end

function SampleSet{T,U}(
    model::Any,
    Ψ::Vector{Vector{U}},
    metadata::Union{Dict{String,Any},Nothing} = nothing,
) where {T,U}
    data = Vector{Sample{T,U}}(undef, length(Ψ))

    for i in eachindex(data)
        ψ = Ψ[i]
        λ = energy(model, ψ)

        data[i] = Sample{T,U}(ψ, λ)
    end

    return SampleSet{T,U}(data, metadata)
end

SampleSet{T}(args...; kws...) where {T}  = SampleSet{T,Int}(args...; kws...)
SampleSet(args...; kws...)               = SampleSet{Float64}(args...; kws...)
Base.copy(ω::SampleSet{T,U}) where {T,U} = SampleSet{T,U}(ω.bits, ω.size, copy(ω.data), deepcopy(ω.metadata))

Base.:(==)(ω::SampleSet{T,U}, η::SampleSet{T,U}) where {T,U} = (ω.data == η.data)

Base.length(ω::SampleSet)  = length(ω.data)
Base.empty!(ω::SampleSet)  = empty!(ω.data)
Base.isempty(ω::SampleSet) = isempty(ω.data)

Base.collect(ω::SampleSet)              = collect(ω.data)
Base.getindex(ω::SampleSet, i::Integer) = ω.data[i]

function Base.append!(ω::SampleSet{T,U}, data::Vector{Sample{T,U}}) where {T,U}
    for s in data
        push!(ω, s)
    end

    return ω
end

function Base.push!(ω::SampleSet{T,U}, s::Sample{T,U}) where {T,U}
    # Fast track
    if value(s) > value(ω[end])
        if length(ω) < ω.size
            push!(ω.data, s)
        end

        return ω
    end

    r = searchsorted(ω.data, s)
    i = first(r)
    j = last(r)

    for k = i:j
        z = ω.data[k]

        if s == z
            ω.data[k] = merge(s, z)

            return ω
        end
    end

    insert!(ω.data, i, s)

    if length(ω) > ω.size
        pop!(ω.data)
    end

    return ω
end

Base.merge!(ω::SampleSet{T,U}, η::SampleSet{T,U}) where {T,U} = append!(ω, collect(η))
Base.merge(ω::SampleSet{T,U}, η::SampleSet{T,U}) where {T,U}  = merge!(copy(ω), η)

metadata(ω::SampleSet) = ω.metadata

function swap_domain(::A, ::B, ω::SampleSet{T,U}) where {A<:𝔻,B<:𝔻,T,U}
    return SampleSet{T,U}(
        ω.bits,
        ω.size,
        swap_domain.(A(), B(), ω),
        deepcopy(metadata(ω))
    )
end