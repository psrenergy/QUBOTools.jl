# -*- :: Domains :: -*- #
abstract type VariableDomain end

@doc raw"""
    SpinDomain <: VariableDomain

```math
s \in \{-1, 1\}
```
""" struct SpinDomain <: VariableDomain end
@doc raw"""
    BoolDomain <: VariableDomain

```math
x \in \{0, 1\}
```
""" struct BoolDomain <: VariableDomain end

# -*- :: Models :: -*- #
abstract type AbstractBQPModel{D<:VariableDomain} end

# ~*~ Validation ~*~ #
function Base.isvalid(::AbstractBQPModel)
    false
end

@doc raw"""
    __isvalidbridge(source::M, target::M, ::Type{<:AbstractBQPModel}; kws...) where M <: AbstractBQPModel

Checks if the `source` model is equivalent to the `target` reference modulo the given origin type.
Key-word arguments `kws...` are passed to interal `isapprox(::T, ::T; kws...)` calls.

""" function __isvalidbridge end

BQPIO.__isvalidbridge(
    source::M,
    target::M,
    ::Type{<:AbstractBQPModel};
    kws...
) where {M<:AbstractBQPModel} = false