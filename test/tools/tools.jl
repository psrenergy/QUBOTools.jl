function test_tools()
    @testset "-*- Tools -*-" begin
        _linear_terms = Dict{Symbol,Float64}(
            :x => 0.5,
            :y => 1.0,
            :z => 2.0,
            :w => -0.25,
            :ξ => 0.0,
        )

        _quadratic_terms = Dict{Tuple{Symbol,Symbol},Float64}(
            (:x, :x) => 0.5,
            (:x, :y) => 1.0,
            (:x, :z) => 2.0,
            (:x, :w) => 3.0,
            (:z, :y) => -1.0,
            (:w, :z) => -2.0,
        )

        _linear_terms, _quadratic_terms, variable_set = BQPIO._normal_form(
            _linear_terms,
            _quadratic_terms
        )

        variable_map, variable_inv = BQPIO._build_mapping(variable_set)

        linear_terms, quadratic_terms = BQPIO._map_terms(
            _linear_terms,
            _quadratic_terms,
            variable_map,
        )

        @test variable_map == Dict{Symbol,Int}(
            :w => 1, :x => 2, :y => 3, :z => 4, :ξ => 5,
        )
        @test variable_inv == Dict{Int,Symbol}(
            1 => :w, 2 => :x, 3 => :y, 4 => :z, 5 => :ξ,
        )
        @test linear_terms == Dict{Int,Float64}(
            1 => -0.25, 2 => 1.0, 3 => 1.0, 4 => 2.0,
        )
        @test quadratic_terms == Dict{Tuple{Int,Int},Float64}(
            (2, 3) => 1.0,
            (2, 4) => 2.0,
            (1, 2) => 3.0,
            (3, 4) => -1.0,
            (1, 4) => -2.0,
        )

        __linear_terms, __quadratic_terms = BQPIO._inv_terms(
            linear_terms,
            quadratic_terms,
            variable_inv,
        )

        @test __linear_terms == Dict{Symbol,Float64}(
            :x => 1.0,
            :y => 1.0,
            :z => 2.0,
            :w => -0.25,
        )
        @test __quadratic_terms == Dict{Tuple{Symbol,Symbol},Float64}(
            (:x, :y) => 1.0,
            (:x, :z) => 2.0,
            (:w, :x) => 3.0,
            (:y, :z) => -1.0,
            (:w, :z) => -2.0,
        )
    end
end