function Base.write(io::IO, model::Qubist)
    println(io, "$(model.sites) $(model.lines)")
    for (i, h) in BQPIO.linear_terms(model; explicit=true)
        println(io, "$(BQPIO.variable_inv(model, i)) $(BQPIO.variable_inv(model, i)) $(h)")
    end
    for ((i, j), J) in BQPIO.quadratic_terms(model)
        println(io, "$(BQPIO.variable_inv(model, i)) $(BQPIO.variable_inv(model, j)) $(J)")
    end
end

function Base.read(io::IO, ::Type{<:Qubist})
    linear_terms = Dict{Int,Float64}()
    quadratic_terms = Dict{Tuple{Int,Int},Float64}()
    sites = nothing
    lines = nothing

    line = strip(readline(io))

    m = match(r"^([0-9]+)\s+([0-9]+)$", line)
    if !isnothing(m)
        sites = tryparse(Int, m[1])
        lines = tryparse(Int, m[2])
    else
        bqpcodec_error("Invalid file header")
    end

    if isnothing(sites) || isnothing(lines)
        bqpcodec_error("Invalid file header")
    end

    for line in strip.(readlines(io))
        m = match(r"^([0-9]+)\s+([0-9]+)\s+([+-]?([0-9]*[.])?[0-9]+)$", line)
        if !isnothing(m)
            i = tryparse(Int, m[1])
            j = tryparse(Int, m[2])
            q = tryparse(Float64, m[3])
            if isnothing(i) || isnothing(j) || isnothing(q)
                bqpcodec_error("Invalid input '$line'")
            elseif i == j
                linear_terms[i] = get(linear_terms, i, 0.0) + q
            else
                quadratic_terms[(i, j)] = get(quadratic_terms, (i, j), 0.0) + q
            end
        else
            bqpcodec_error("Invalid input '$line'")
        end
    end

    Qubist{SpinDomain}(
        linear_terms,
        quadratic_terms;
        sites=sites,
        lines=lines
    )
end

BQPIO.infer_model_type(::Val{:qh}) = Qubist