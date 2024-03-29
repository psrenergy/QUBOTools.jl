@doc raw"""
    AbstractModel{V,T,U}

Represents an abstract QUBO Model.

As shown in the example above, implementing a method for the [`QUBOTools.backend`](@ref) function
gives access to most fallback implementations.
"""
abstract type AbstractModel{V,T,U} end

@doc raw"""
    backend(model)::AbstractModel
    backend(model::AbstractModel)::AbstractModel

Accesses the model's backend.
Implementing this function allows one to profit from fallback implementations of other methods.
"""
function backend end

@doc raw"""
    Domain

Enum representing binary variable domains, `BoolDomain` and `SpinDomain`.
"""
@enum Domain begin
    BoolDomain
    SpinDomain
end

Base.Broadcast.broadcastable(X::Domain) = Ref(X)

@doc raw"""
    BoolDomain

Represents the boolean domain ``\mathbb{B} = \lbrace{0, 1}\rbrace``.

## Properties

```math
x \in \mathbb{B}, n \in \mathbb{N} \implies x^{n} = x
```
"""
BoolDomain

const 𝔹 = BoolDomain

@doc raw"""
    SpinDomain

Represents the spin domain ``\mathbb{S} = \lbrace{-1, 1}\rbrace``.

## Properties

```math
s \in \mathbb{S}, n \in \mathbb{Z} \implies s^{2n} = 1, s^{2n + 1} = s
```
"""
SpinDomain

const 𝕊 = SpinDomain

@doc raw"""
    domain(model::AbstractModel)

Returns the variable domain of a given model.
"""
function domain end

@doc raw"""
    scale(model::AbstractModel)
    scale(model::AbstractForm)

Returns the scaling factor of a model.
"""
function scale end

@doc raw"""
    offset(model::AbstractModel)
    offset(model::AbstractForm)

Returns the constant offset factor of a model.
"""
function offset end

@doc raw"""
    Sense

Enum representing the minimization and maximization objective senses, `Min` and `Max`.
"""
@enum Sense begin
    Min
    Max
end

Base.Broadcast.broadcastable(s::Sense) = Ref(s)

@doc raw"""
    sense(model)

Returns the objective sense of a model.
"""
function sense end

@doc raw"""
    id(model)

Returns a model identifier as an `Int` or `nothing`.
"""
function id end

@doc raw"""
    version(fmt::AbstractFormat)

Returns the version of a format protocol as a `VersionNumber` or `nothing`.
"""
function version end

@doc raw"""
    description(model)

Returns the model description as a `String` or `nothing`.
"""
function description end

@doc raw"""
    data(form)
    data(sol::AbstractSolution)

Retrieves the raw data behind solution and form wrappers.
"""
function data end

@doc raw"""
    metadata(model::AbstractModel)
    metadata(sol::AbstractSolution)

Retrieves metadata from a model or solution as a JSON-compatible `Dict{String,Any}`.
"""
function metadata end

@doc raw"""
    linear_terms(model::AbstractModel{V,T,U}) where {V,T,U}

Returns an iterator for the linear nonzero terms of a model as `Int => T` pairs.
"""
function linear_terms end

@doc raw"""
    quadratic_terms(model::AbstractModel{V,T,U}) where {V,T,U}

Returns an iterator for the quadratic nonzero terms of a model as `Tuple{Int,Int} => T` pairs.

!!! info
    For every key pair ``(i, j)`` we have that ``i < j``.
"""
function quadratic_terms end

@doc raw"""
    index(model::AbstractModel{V}, v::V) where {V}

Given a variable, returns the corresponding index.
"""
function index end

@doc raw"""
    hasindex(model::AbstractModel, i::Integer)::Bool

Given an index, returns whether it is valid for rhe model.
"""
function hasindex end

@doc raw"""
    indices(model)

Returns a sorted vector ``[1, \dots, n]`` that matches the variable indices,
where ``n`` is the model's dimension.
"""
function indices end

@doc raw"""
    variable(model::AbstractModel, i::Integer)

Given an index, returns the corresponding variable.
"""
function variable end

@doc raw"""
    hasvariable(model::AbstractModel{V}, v::V)::Bool where {V}

Given a variable, tells if it belongs to the model.
"""
function hasvariable end

@doc raw"""
    variables(model)

Returns a sorted vector containing the model's variables.
"""
function variables end

@doc raw"""
    start(model::AbstractModel{V,T,U}; domain = domain(model))::Dict{Int,U} where {V,T,U}

Returns a dictionary containing a warm-start value for each variable index.
"""
function start end

# Queries: sizes & density
@doc raw"""
    dimension(model)::Integer

Counts the total number of variables in the model.
"""
function dimension end

@doc raw"""
    linear_size(model)

Counts the number of non-zero linear terms in the model.
"""
function linear_size end

@doc raw"""
    quadratic_size(model)

Counts the number of non-zero quadratic terms in the model.
"""
function quadratic_size end

@doc raw"""
    read_model(::AbstractString)
    read_model(::AbstractString, ::AbstractFormat)
    read_model(::IO, ::AbstractFormat)
"""
function read_model end

@doc raw"""
    write_model(::AbstractString, ::AbstractModel)
    write_model(::AbstractString, ::AbstractModel, ::AbstractFormat)
    write_model(::IO, ::AbstractModel, ::AbstractFormat)
"""
function write_model end

@doc raw"""
    attach!(model::AbstractModel{V,T,U}, sol::AbstractSolution{T,U}) where {V,T,U}

Attaches solution to model, replacing existing data and solution metadata. It
automatically casts the solution to the model frame upon attachment.
"""
function attach! end
