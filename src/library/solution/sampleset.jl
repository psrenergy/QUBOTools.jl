@doc raw"""
    SampleSet{T,U}(
        data::Vector{Sample{T,U}},
        metadata::Dict{String,Any};
        sense::Union{Sense,Symbol}   = :min,
        domain::Union{Domain,Symbol} = :bool,
    ) where {T,U}

It compresses repeated states by adding up the `reads` field.
It was inspired by [^dwave], with a few tweaks.

!!! info
    A `SampleSet{T,U}` was designed to be read-only.
    It is optimized to support queries over the solution set.

## References
[^dwave]:
    [ocean docs](https://docs.ocean.dwavesys.com/en/stable/docs_dimod/reference/S.html#dimod.SampleSet)
"""
struct SampleSet{T,U} <: AbstractSolution{T,U}
    data::Vector{Sample{T,U}}
    metadata::Dict{String,Any}
    frame::Frame

    function SampleSet{T,U}(
        data::V,
        metadata::Union{Dict{String,Any},Nothing} = nothing;
        sense::Union{Sense,Symbol} = :min,
        domain::Union{Domain,Symbol} = :bool,
    ) where {T,U,S<:Sample{T,U},V<:AbstractVector{S}}
        data = _sort_and_merge(data)

        if isnothing(metadata)
            metadata = Dict{String,Any}()
        end

        return new{T,U}(data, metadata, Frame(sense, domain))
    end

    function SampleSet{T,U}(
        metadata::Dict{String,Any};
        sense::Union{Sense,Symbol}   = :min,
        domain::Union{Domain,Symbol} = :bool,
    ) where {T,U}
        return new{T,U}(Sample{T,U}[], metadata, Frame(sense, domain))
    end
end

function SampleSet{T,U}(;
    sense::Union{Sense,Symbol}   = :min,
    domain::Union{Domain,Symbol} = :bool,
) where {T,U}
    return SampleSet{T,U}(Sample{T,U}[], Dict{String,Any}(); sense, domain)
end

function SampleSet{T,U}(
    x,
    Ψ::AbstractVector{S},
    metadata::Union{Dict{String,Any},Nothing} = nothing,
) where {T,U,S<:State{U}}
    data = Vector{Sample{T,U}}(undef, length(Ψ))

    for i in eachindex(data)
        ψ = Ψ[i]
        λ = value(x, ψ)

        data[i] = Sample{T,U}(ψ, λ)
    end

    return SampleSet{T,U}(data, metadata; sense = sense(x), domain = domain(x))
end

SampleSet{T}(args...; kws...) where {T} = SampleSet{T,Int}(args...; kws...)
SampleSet(args...; kws...)              = SampleSet{Float64}(args...; kws...)

Base.copy(sol::SampleSet{T,U}) where {T,U} = SampleSet{T,U}(
    collect(sol),
    deepcopy(metadata(sol));
    sense = sense(sol),
    domain = domain(sol),
)

Base.:(==)(sol::SampleSet{T,U}, η::SampleSet{T,U}) where {T,U} = (sol.data == η.data)

Base.length(sol::SampleSet)  = length(sol.data)
Base.isempty(sol::SampleSet) = isempty(sol.data)

Base.collect(sol::SampleSet)              = collect(sol.data)
Base.getindex(sol::SampleSet, i::Integer) = sol.data[i]

Base.iterate(sol::SampleSet)             = iterate(sol.data)
Base.iterate(sol::SampleSet, i::Integer) = iterate(sol.data, i)

metadata(sol::SampleSet) = sol.metadata

frame(sol::SampleSet)  = sol.frame
sense(sol::SampleSet)  = sense(frame(sol))
domain(sol::SampleSet) = domain(frame(sol))

function cast(route::Route{S}, sol::SampleSet{T,U}) where {T,U,S<:Sense}
    return SampleSet{T,U}(
        Vector{Sample{T,U}}(cast.(route, sol)),
        deepcopy(metadata(sol));
        sense  = last(route),
        domain = domain(sol),
    )
end

function cast(route::Route{D}, sol::SampleSet{T,U}) where {T,U,D<:Domain}
    return SampleSet{T,U}(
        Vector{Sample{T,U}}(cast.(route, sol)),
        deepcopy(metadata(sol));
        sense  = sense(sol),
        domain = last(route),
    )
end
