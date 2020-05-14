using Test
using StaticArrays
using PolygonArea
using PolygonArea: Point, rotate, translate

@testset "Points" begin
    p = Point(1.0, 0.0)
    @test rotate(p, π/2) ≈ Point(0.0, 1.0)
    @test rotate(p, π/2, center=Point(2.0, 0.0)) ≈ Point(2.0, -1.0)
    @test translate(p, SVector(1.0, 0.0)) ≈ Point(2.0, 0.0)
end
