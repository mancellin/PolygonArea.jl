using Test
using PolygonArea
using PolygonArea: PolarHalfPlane, Point, corner_point, Intersection, Reunion
using PolygonArea: signed_distance, distance, outward_normal, angle
using PolygonArea: complement, rotate, translate, distance, exchange_x_and_y
using StaticArrays

@testset "Half-planes" begin

    @testset "creation and equality" begin
        @test HalfPlane(1.0, 0.0, 0.0) isa HalfPlane{Float64}
        @test PolarHalfPlane(0.0, π, center=(1.0, 1.0)) isa HalfPlane{Float64}

        @test HalfPlane(1, 0, 0) isa HalfPlane{Int}
        @test HalfPlane{Float64}(1, 0, 0) isa HalfPlane{Float64}

        @test HalfPlane((0.0, 0.0), (1.0, 0.0)) ≈ HalfPlane(0.0, 1.0, 0.0)

        @test HalfPlane(1.0, 0.0, 0.0) == HalfPlane(1.0, 0.0, 0.0)
        @test HalfPlane(1.0, 0.0, 0.0) != HalfPlane(1.0, 1e-15, 0.0)
        @test HalfPlane(1.0, 0.0, 0.0) ≈ HalfPlane(1.0, 0.0, 0.0)
    end

    @testset "contained points" begin
        @test Point(0, -1)   in HalfPlane(0, 1, 0)
        @test Point(0, -1)   in HalfPlane(0.0, 1.0, 0.0)
        @test Point(0, 0)    in HalfPlane(0, 1, 0)
        @test !(Point(0, 1)  in HalfPlane(0, 1, 0))
        @test Point(1, 0)    in HalfPlane(-1, 0, 0)
        @test !(Point(-1, 0) in HalfPlane(-1, 0, 0))

        @test (-1.0, -1.0) ∈ HalfPlane((0.0, 0.0), (1.0, 0.0), :right)
        @test (1.0, 1.0) ∈ HalfPlane((0.0, 0.0), (1.0, 0.0), :left)

        @test Point(0.5, 0.5) in PolarHalfPlane(-1.0, 0π)
        @test (0.5, 0.5) in PolarHalfPlane(-1.0, 0π)

        @test Point(0.5, 0.5) in PolarHalfPlane(-1.0, π/2)
        @test Point(0.5, 0.5) in PolarHalfPlane(-1.0, π)
        @test Point(0.5, 0.5) in PolarHalfPlane(-1.0, 3π/2)
        @test Point(1.0, 1.0) in PolarHalfPlane(-1.0, 0π)
        @test Point(0.5, 2.0) in PolarHalfPlane(-1.0, 0π)
        @test Point(2.0, 0.5) in PolarHalfPlane(-1.0, π/2)
        @test Point(0.0, 3.0) in PolarHalfPlane(-1.0, π)
    end

    @testset "properties" begin
        @test signed_distance((0.0, 0.0), PolarHalfPlane(-4.0, 2π/3)) ≈ -4.0
        @test signed_distance((0.0, 0.0), PolarHalfPlane(4.0, π/3)) ≈ 4.0

        # Works with Points (SVector) as well as tuples
        @test distance(Point(9.0, 0.0), PolarHalfPlane(0.0, 0.0)) ≈ 9.0
        @test distance((9.0, 0.0), PolarHalfPlane(0.0, 0.0)) ≈ 9.0

        # Scaling of the definition of the plane
        @test distance((1.0, 1.0), HalfPlane(-1.0, 0.0, 0.0)) == distance((1.0, 1.0), HalfPlane(-2.0, 0.0, 0.0))
        @test distance((1.0, 1.0), HalfPlane(-1.0, -1.0, 0.0)) == distance((1.0, 1.0), HalfPlane(-2.0, -2.0, 0.0))

        @test distance((9.0, 0.0), PolarHalfPlane(1.0, 0.0)) ≈ 10.0
        @test distance((9.0, -10.0), PolarHalfPlane(1.0, 0.0)) ≈ 10.0
        @test distance((9.0, 1.0), PolarHalfPlane(0.0, π/2)) ≈ 1.0
        @test distance((1.0, 1.0), PolarHalfPlane(0.0, π/4)) ≈ √2
        @test distance((2.0, 2.0), PolarHalfPlane(-√2, π/4)) ≈ √2
        @test distance((6.0, 1.0), PolarHalfPlane(0.0, π/4, center=Point(5.0, 0.0))) ≈ √2

        @test angle(PolarHalfPlane(0.0, π/8)) ≈ π/8
        @test angle(PolarHalfPlane(0.0, -π/8)) ≈ mod(-π/8, 2π)
        @test angle(PolarHalfPlane(4.0, π/3)) ≈ π/3

        @test outward_normal(HalfPlane(1.0, 0.0, 0.0)) == SVector(1.0, 0.0)
        @test outward_normal(HalfPlane(0.0, 1.0, rand(1)[1])) == SVector(0.0, 1.0)
    end

    @testset "transformations" begin
        # Rotate
        @test isapprox(outward_normal(rotate(PolarHalfPlane(0π), π)), outward_normal(PolarHalfPlane(π)))
        @test isapprox(outward_normal(rotate(PolarHalfPlane(0π, center=(1.0, 1.0)), π)), outward_normal(PolarHalfPlane(π)))
        @test isapprox(outward_normal(rotate(PolarHalfPlane(π/2, center=(1.0, 1.0)), π)), outward_normal(PolarHalfPlane(3π/2)))

        @test (PolarHalfPlane(0.234π) |> rotate(π) |> rotate(-π)) ≈ PolarHalfPlane(0.234π)
        @test (PolarHalfPlane(0.234π) |> rotate(π) |> rotate(π)) ≈ PolarHalfPlane(0.234π)

        @test Point(1.0, 0.0) in rotate(HalfPlane(1.0, 0.0, 0.0) ∪ HalfPlane(1.0, 0.1, 0.0), π)
        @test Point(1.0, 0.0) in rotate(HalfPlane(1.0, 0.0, 0.0) ∩ HalfPlane(1.0, 0.1, 0.0), π)

        # Translate
        @test outward_normal(translate(PolarHalfPlane(0π), SVector{2}(1.0, 1.0))) == outward_normal(PolarHalfPlane(0π))
        @test distance(Point(2.0, 0.0), translate(PolarHalfPlane(0π), SVector{2}(1.0, 1.0))) == 1.0
        @test Point(1.0, 0.0) in translate(HalfPlane(1.0, 0.0, 0.0), SVector(2.0, 0.0))

        @test Point(1.0, 0.0) in translate(HalfPlane(1.0, 0.0, 0.0) ∪ HalfPlane(1.0, 0.1, 0.0), SVector(2.0, 0.0))
        @test Point(1.0, 0.0) in translate(HalfPlane(1.0, 0.0, 0.0) ∩ HalfPlane(1.0, 0.1, 0.0), SVector(2.0, 0.0))

        @test translate(HalfPlane(1.0, 0.0, 0.0), SVector(2.0, 0.0)) == (HalfPlane(1.0, 0.0, 0.0) |> translate(SVector(2.0, 0.0)))

        # Exchange x and y
        @test isapprox(exchange_x_and_y(PolarHalfPlane(0.0, 0.0)), PolarHalfPlane(0.0, π/2), atol=1e-14)
        @test isapprox(exchange_x_and_y(PolarHalfPlane(1.0, 0.0)), PolarHalfPlane(1.0, π/2), atol=1e-14)
        @test isapprox(exchange_x_and_y(PolarHalfPlane(0.0, 0.0, center=Point(1.0, 0.0))), PolarHalfPlane(0.0, π/2, center=Point(0.0, 1.0)), atol=1e-14)
    end

    @testset "unions, intersections and corners" begin
        inferior_hp = HalfPlane(0, 1, 0)
        right_hp = HalfPlane(-1, 0, 0)
        @test Point(1, -1) in intersect(inferior_hp, right_hp)
        @test Point(1, -1) in inferior_hp ∩ right_hp
        @test !(Point(1, 1) in intersect(inferior_hp, right_hp))
        @test Point(1, 1) in complement(inferior_hp ∩ right_hp)
        @test Point(1, 1) in complement(inferior_hp ∪ complement(right_hp))

        @test !(Point(-1, 1) in union(inferior_hp, right_hp))
        @test (Point(1, 1) in union(inferior_hp, right_hp))

        @test corner_point(HalfPlane(0.0, 1.0, 0.0), HalfPlane(-1.0, 0.0, 0.0)) == Point(0.0, 0.0)
        @test corner_point(HalfPlane(1.0, 0.0, 1.0), HalfPlane(0.0, -1.0, 0.5)) == Point(-1.0, 0.5)
        @test corner_point(PolarHalfPlane(0.0, 0.0), HalfPlane(0.0, 1.0, -1.0)) == Point(0.0, 1.0)
        @test corner_point(PolarHalfPlane(-1.0, π/2, center=Point(0.5, 0.5)), HalfPlane(1.0, 0.0, -1.0)) == Point(1.0, 1.5)

        # Union and intersection
        h1 = HalfPlane(1.0, 0.0, 0.0)
        @test ((h1 ∩ h1) ∪ (h1 ∩ h1)) isa Reunion{Intersection{HalfPlane{Float64}}}
        @test ((h1 ∪ h1) ∩ (h1 ∪ h1)) isa Reunion{Intersection{HalfPlane{Float64}}}

        HalfPlane(1.0, 0.0, 0.0) ∪ HalfPlane(0.0, 1.0, 0.0) ∩ (HalfPlane(1.0, 0.0, 0.0) ∪ HalfPlane(0.0, 1.0, 0.0))

        @test Point(0.0, 0.0) in ((h1 ∪ h1) ∩ (h1 ∪ h1) |> complement)
    end

    @testset "conversion" begin
        a = HalfPlane{Int}(1, 1, 1)
        b = HalfPlane{Int}(-1, 1, 1)
        @test convert(Reunion{Intersection{HalfPlane{Int}}}, a ∪ b) isa Reunion{Intersection{HalfPlane{Int}}}
    end

end
