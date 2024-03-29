function Base.isempty(model::AbstractModel)
    return iszero(dimension(model))
end

function Base.broadcastable(model::AbstractModel)
    return Ref(model) # Broadcast over model as scalar
end

function indices(model::AbstractModel)
    return collect(1:dimension(model))
end

function hasindex(model::AbstractModel, i::Integer)
    return 1 <= i <= dimension(model)
end

function variable(model::AbstractModel{V}, i::Integer) where {V}
    if hasindex(model, i)
        mapping = variables(model)::AbstractVector{V}

        return mapping[i]
    else
        error("Variable with index '$i' does not belong to the model")
    end
end

function hasvariable(model::AbstractModel{V}, v::V) where {V}
    return v ∈ variables(model)
end

# ~*~ Model's Normal Forms ~*~ #
function form(
    model::AbstractModel{V,T,U},
    ::Type{F};
    domain = domain(model),
) where {V,T,U,X,F<:AbstractForm{X}}
    Φ = form(model)

    if !(Φ isa F)
        return cast((QUBOTools.domain(model) => domain), Φ)
    else
        return cast((QUBOTools.domain(model) => domain), F(Φ))
    end
end

# ~*~ Data queries ~*~ #
function hassample(model::AbstractModel, i::Integer)
    return hassample(solution(model), i)
end

function sample(model::AbstractModel, i::Integer)
    return sample(solution(model), i)
end

function state(model::AbstractModel, i::Integer)
    return state(solution(model), i)
end

function reads(model::AbstractModel)
    return reads(solution(model))
end

function reads(model::AbstractModel, i::Integer)
    return reads(solution(model), i)
end

function value(model::AbstractModel, i::Integer)
    return value(solution(model), i)
end

function value(model::AbstractModel, ψ::State{U}) where {U}
    return value(ψ, form(model))
end

# Queries: Dimensions
dimension(model::AbstractModel)      = dimension(form(model))
linear_size(model::AbstractModel)    = linear_size(form(model))
quadratic_size(model::AbstractModel) = quadratic_size(form(model))

# Queries: Layout, Topology & Geometry
topology(model::AbstractModel) = topology(form(model))
geometry(model::AbstractModel) = geometry(topology(model))

# Queries: Metadata
function id(model::AbstractModel)
    return get(metadata(model), "id", nothing)
end

function description(model::AbstractModel)
    return get(metadata(model), "description", nothing)
end

# ~*~ I/O ~*~ #
function Base.show(io::IO, model::AbstractModel)
    if isempty(model)
        print(
            io,
            """
            QUBOTools Model
            ▷ Sense ………………… $(sense(model))
            ▷ Domain ……………… $(domain(model))

            The model is empty.
            """,
        )

        return nothing
    else
        println(
            io,
            """
            QUBOTools Model
            ▷ Sense ………………… $(sense(model))
            ▷ Domain ……………… $(domain(model))
            ▷ Variables ……… $(dimension(model))

            Density:
            ▷ Linear ……………… $(Printf.@sprintf("%6.2f", 100.0 * linear_density(model)))%
            ▷ Quadratic ……… $(Printf.@sprintf("%6.2f", 100.0 * quadratic_density(model)))%
            ▷ Total ………………… $(Printf.@sprintf("%6.2f", 100.0 * density(model)))%
            """,
        )
    end

    if isempty(start(model))
        print(
            io,
            """
            There are no warm-start values.
            """
        )
    else
        print(
            io,
            """
            Warm-start:
            ▷ Sites ………………… $(length(start(model)))/$(dimension(model))
            """
        )
    end

    println(io)

    if isempty(solution(model))
        print(
            io,
            """
            There are no solutions available.
            """,
        )
    else
        sol = solution(model)
        n   = length(sol)
        z   = value(sol, 1)

        print(
            io,
            """
            Solutions:
            ▷ Samples …………… $(n)
            ▷ Best value …… $(z)
            """,
        )
    end

    return nothing
end
