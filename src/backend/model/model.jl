@doc raw"""
    StandardBQPModel{
        S <: Any,
        U <: Integer,
        T <: Real,
        D <: VariableDomain
    } <: AbstractBQPModel{D}

The `StandardBQPModel` was designed to work as a general for all implemented interfaces.
It is intended to be the core engine behind the target codecs.

## MathOptInterface/JuMP
Both `S <: Any` and `T <: Real` parameters exist to support MathOptInterface/JuMP integration.
By choosing `S = MOI.VariableIndex` and `T` matching `Optimizer{T}` the hard work should be done.

""" mutable struct StandardBQPModel{
    S<:Any,
    U<:Integer,
    T<:Real,
    D<:VariableDomain
} <: AbstractBQPModel{D}
    # ~*~ Required data ~*~
    linear_terms::Dict{Int,T}
    quadratic_terms::Dict{Tuple{Int,Int},T}
    variable_map::Dict{S,Int}
    variable_inv::Dict{Int,S}
    # ~*~ Sense ~*~
    sense::Symbol
    # ~*~ Factors ~*~
    offset::Union{T,Nothing}
    scale::Union{T,Nothing}
    # ~*~ Metadata ~*~
    id::Union{Int,Nothing}
    version::Union{VersionNumber,Nothing}
    description::Union{String,Nothing}
    metadata::Union{Dict{String,Any},Nothing}
    # ~*~ Solutions ~*~
    sampleset::Union{SampleSet{U,T},Nothing}

    function StandardBQPModel{S,U,T,D}(
        # ~*~ Required data ~*~
        linear_terms::Dict{Int,T},
        quadratic_terms::Dict{Tuple{Int,Int},T},
        variable_map::Dict{S,Int},
        variable_inv::Dict{Int,S};
        # ~*~ Sense ~*~
        sense::Symbol=:min,
        # ~*~ Factors ~*~
        offset::Union{T,Nothing}=nothing,
        scale::Union{T,Nothing}=nothing,
        # ~*~ Metadata ~*~
        id::Union{Integer,Nothing}=nothing,
        version::Union{VersionNumber,Nothing}=nothing,
        description::Union{String,Nothing}=nothing,
        metadata::Union{Dict{String,Any},Nothing}=nothing,
        # ~*~ Solutions ~*~
        sampleset::Union{SampleSet{U,T},Nothing}=nothing
    ) where {S,U,T,D}
        @assert sense == :min || sense == :max

        new{S,U,T,D}(
            linear_terms,
            quadratic_terms,
            variable_map,
            variable_inv,
            sense,
            offset,
            scale,
            id,
            version,
            description,
            metadata,
            sampleset,
        )
    end

    function StandardBQPModel{S,U,T,D}(
        # ~*~ Required data ~*~
        _linear_terms::Dict{S,T},
        _quadratic_terms::Dict{Tuple{S,S},T};
        kws...
    ) where {S,U,T,D}
        # ~ What is happening now: There were many layers of validation
        #   before we got here. This call to `_normal_form` removes any re-
        #   dundancy by aggregating (i, j) and (j, i) terms and also ma-
        #   king "quadratic" terms with i == j  into linear ones. Also,
        #   zeros are removed, improving sparsity in this last step.
        # ~ New objects are created not to disturb the original ones.
        _linear_terms, _quadratic_terms, variable_set = BQPIO._normal_form(
            _linear_terms,
            _quadratic_terms,
        )

        variable_map, variable_inv = BQPIO._build_mapping(variable_set)

        linear_terms, quadratic_terms = BQPIO._map_terms(
            _linear_terms,
            _quadratic_terms,
            variable_map,
        )

        StandardBQPModel{S,U,T,D}(
            linear_terms,
            quadratic_terms,
            variable_map,
            variable_inv;
            kws...
        )
    end

    function StandardBQPModel{S,U,T,D}(; kws...) where {S,U,T,D}
        StandardBQPModel{S,U,T,D}(
            Dict{S,T}(),
            Dict{Tuple{S,S},T}();
            kws...
        )
    end

    # ~ aliasing ~
    function StandardBQPModel{S,T,D}(args...; kws...) where {S,T,D}
        StandardBQPModel{S,Int,T,D}(args...; kws...)
    end

    function StandardBQPModel{S,D}(args...; kws...) where {S,D}
        StandardBQPModel{S,Int,Float64,D}(args...; kws...)
    end

    function StandardBQPModel{D}(args...; kws...) where {D}
        StandardBQPModel{Int,Int,Float64,D}(args...; kws...)
    end
end

function Base.empty!(model::StandardBQPModel)
    empty!(model.linear_terms)
    empty!(model.quadratic_terms)
    empty!(model.variable_map)
    empty!(model.variable_inv)
    model.offset = nothing
    model.scale = nothing
    model.id = nothing
    model.version = nothing
    model.description = nothing
    model.metadata = nothing
    model.sampleset = nothing

    return model
end

function Base.isempty(model::StandardBQPModel)
    return isempty(model.linear_terms) &&
           isempty(model.quadratic_terms) &&
           isempty(model.variable_map) &&
           isempty(model.variable_inv) &&
           isnothing(model.offset) &&
           isnothing(model.scale) &&
           isnothing(model.id) &&
           isnothing(model.version) &&
           isnothing(model.description) &&
           isnothing(model.metadata) &&
           isnothing(model.sampleset)
end

function Base.copy(model::StandardBQPModel{S,U,T,D}) where {S,U,T,D}
    StandardBQPModel{S,U,T,D}(
        copy(model.linear_terms),
        copy(model.quadratic_terms),
        copy(model.variable_map),
        copy(model.variable_inv);
        offset=model.offset,
        scale=model.scale,
        id=model.id,
        version=model.version,
        description=model.description,
        metadata=deepcopy(model.metadata),
        sampleset=model.sampleset
    )
end

function BQPIO.__isvalidbridge(
    source::StandardBQPModel{S,U,T,D},
    target::StandardBQPModel{S,U,T,D};
    kws...
) where {S,U,T,D}
    flag = true

    if !isnothing(source.id) && !isnothing(target.id) && (source.id != target.id)
        @error """
        Test Failure: ID mismatch:
        $(source.id) ≂̸ $(target.id)
        """
        flag = false
    end

    if !isnothing(source.description) && !isnothing(target.description) && (source.description != target.description)
        @error """
        Test Failure: Description mismatch:
        $(source.description) ≂̸ $(target.description)
        """
        flag = false
    end

    if !isnothing(source.metadata) && !isnothing(target.metadata) && (source.metadata != target.metadata)
        @error "Test Failure: Metadata mismatch"
        flag = false
    end

    if !isapproxdict(source.linear_terms, target.linear_terms; kws...)
        @error """
        Test Failure: Linear terms mismatch:
        $(source.linear_terms) ≉ $(target.linear_terms)
        """
        flag = false
    end

    if !isapproxdict(source.quadratic_terms, target.quadratic_terms; kws...)
        @error """
        Test Failure: Quadratic terms mismatch:
        $(source.quadratic_terms) ≉ $(target.quadratic_terms)
        """
        flag = false
    end

    if !isnothing(source.offset) && !isnothing(target.offset) && !isapprox(source.offset, target.offset; kws...)
        @error """
        Test Failure: Offset mismatch:
        $(source.offset) ≂̸ $(target.offset)
        """
        flag = false
    end

    if !isnothing(source.scale) && !isnothing(target.scale) && !isapprox(source.scale, target.scale; kws...)
        @error """
        Test Failure: Scale mismatch:
        $(source.scale) ≠ $(target.scale)
        """
        flag = false
    end

    return flag
end