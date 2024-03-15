function Base.write(io::IO, model::HFS)
    if isempty(model.variable_ids)
        @warn "Empty HFS file produced"
        println(io, "0 0")
        return
    end    

    # Output the hfs data file
    # it is a header followed by linear terms and then quadratic terms
    println(io, "$(model.chimera_effective_degree) $(model.chimera_effective_degree)")

    for (i, q) in model.int_linear_terms
        args = [
            collect(model.chimera_coordinate[i]);
            collect(model.chimera_coordinate[i]);
            q
        ]
        println(io, Printf.@sprintf("%2d %2d %2d %2d    %2d %2d %2d %2d    %8d", args...))
    end

    for ((i, j), Q) in model.int_quadratic_terms
        args = [
            collect(model.chimera_coordinate[i]);
            collect(model.chimera_coordinate[j]);
            Q
        ]
        println(io, Printf.@sprintf("%2d %2d %2d %2d    %2d %2d %2d %2d    %8d", args...))
    end
end

BQPIO.infer_model_type(::Val{:hfs}) = HFS