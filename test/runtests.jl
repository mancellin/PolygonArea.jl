using PolygonArea
using Test

@testset "PolygonArea.jl" begin
    include("test_points.jl")
    include("test_halfplanes.jl")
    include("test_polygons.jl")
end
