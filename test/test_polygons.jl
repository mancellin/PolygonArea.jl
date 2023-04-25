using Test
using StaticArrays
using PolygonArea
using PolygonArea: PolarHalfPlane, Reunion, Point, vertices, complement, rotate, translate, scale, square

@testset "Polygons" begin

    @testset "creation and contained points" begin
        unit_square = square((0.0, 0.0), 1.0)
        @test Point(0.5, 0.5) in unit_square
        @test Point(1.0, 1.0) in unit_square
        @test !(Point(1.2, 1.0) in unit_square)
        @test Point(0.0, 0.0) in vertices(unit_square)
        @test Point(1.0, 0.0) in vertices(unit_square)
        @test !(Point(0.5, 0.5) in vertices(unit_square))
            
        @test unit_square == rectangle(bottom_left=(0.0, 0.0), top_right=(1.0, 1.0))
        @test unit_square == rectangle(bottom_left=(0.0, 0.0), top_right=(1.0, 1.0))
        @test unit_square == rectangle((0.0, 0.0), (1.0, 1.0))

        @test !(PolygonArea.ConvexPolygon{Int}([]) == square((1, 1), 1))

        rec = PolygonArea.ConvexPolygon([(0.0, 0.0), (0.0, 1.0), (1.0, 1.0), (1.0, 0.0)])
        @test (0.5, 0.5) ∈ rec

        # Should return an error...
        inv_rec = PolygonArea.ConvexPolygon([(0.0, 0.0), (1.0, 0.0), (1.0, 1.0), (0.0, 1.0)])
        @test !((0.5, 0.5) ∈ inv_rec)
    end

    @testset "properties" begin
        @test isempty(PolygonArea.ConvexPolygon{Int}([]))

        @test PolygonArea.nb_sides(rectangle((0, 0), (2, 2))) == 4

        @test area(PolygonArea.square((0.0, 0.0), 1.0)) == 1.0
        @test area(rectangle((0, 0), (4, 3))) == 12
        @test isapprox(area(circle(Point(0.0, 0.0), 1.0, 100)), π, atol=1e3)
    end

    @testset "transformations" begin
        @test Point(0.0, 1.2) in rotate(rectangle(0.0, 0.0, 1.0, 1.0), π/4)
        @test Point(0.0, 1.2) in translate(rectangle(0.0, 0.0, 1.0, 1.0), SVector(-0.3, 0.5))
        @test Point(0.0, 1.2) in translate(rectangle(0.0, 0.0, 1.0, 1.0), [-0.3, 0.5])
        @test Point(0.0, 1.2) in translate(rectangle(0.0, 0.0, 1.0, 1.0), (-0.3, 0.5))
        @test Point(1.5, 1.5) in scale(rectangle(0.0, 0.0, 1.0, 1.0), 1.5)
        @test !(Point(1.5, 1.5) in scale(rectangle(0.0, 0.0, 1.0, 1.0), 1.5, center=(1.0, 1.0)))
        λ = rand(2)
        @test area(scale(rectangle(0.0, 0.0, 1.0, 1.0), λ)) ≈ prod(λ)*area(rectangle(0.0, 0.0, 1.0, 1.0)) 
    end

    @testset "union and intersection" begin
        # Intersection with HalfPlane
        unit_square = square((0.0, 0.0), 1.0)
        hp = HalfPlane(1.0, 1.0, -1.5)
        c1 = unit_square ∩ hp  # Cut the top-right corner
        @test Point(0.5, 0.5) in c1
        @test !(Point(0.9, 0.9) in c1)

        c2 = unit_square ∩ complement(hp)  # Keep only the top-right corner
        @test !(Point(0.5, 0.5) in c2)
        @test Point(0.9, 0.9) in c2

        @test area(c1) + area(c2) ≈ area(unit_square)

        # Intersection with union and intersection of HalfPlanes
        left = HalfPlane(1.0, 0.0, -0.5)
        top = HalfPlane(0.0, 1.0, -0.5)
        top_left = top ∩ left
        bottom_right = complement(top) ∩ complement(left)
        @test bottom_right == complement(top ∪ left)
        @test (unit_square ∩ left) ∩ top == unit_square ∩ (left ∩ top)

        @test area(unit_square ∩ left) == 0.5
        @test area((unit_square ∩ left) ∩ top) == 0.25
        @test area(unit_square ∩ (top ∪ left)) == 0.75

        @test area(unit_square ∩ (bottom_right ∪ top_left)) ≈ 0.5
        @test area(unit_square ∩ (bottom_right ∩ top_left)) ≈ 0.0

        @test (square((0.0, 0.0), 1.0) |> complement |> typeof) == Reunion{HalfPlane{Float64}}
        @test area(square((0.0, 0.0), 3.0) \ square((1.0, 1.0), 1.0)) == 8.0

        # Intersection with ConvexPolygon
        @test area(unit_square ∩ square((0.0, 0.5), 1.0)) == 0.5
        @test area(unit_square ∩ square((0.5, 0.5), 1.0)) == 0.25

        triangle = ConvexPolygon([(0.0, 0.0), (0.5, 1.0), (1.0, 0.0)])
        @test area(unit_square ∩ triangle) == area(triangle)
       
        # Intersection with union of ConvexPolygon
        r1 = rectangle(0.0, 0.0, 2.0, 2.0)
        r2 = rectangle(1.0, 1.0, 2.0, 2.0)
        r3 = rectangle(1.5, 1.5, 2.5, 2.5)
        @test area((unit_square ∪ r2) ∩ (r1 ∪ r3)) == 2.0

        # Intersection with circle
        c = circle(0.0, 0.0, 1.0, 100)
        r = rectangle(0.0, -1.0, 1.0, 1.0)
        @test area(c ∩ r) ≈ area(r ∩ c) ≈ area(c)/2

        # Disjoint union
        c = circle(0.0, 0.0, 1.0, 10)
        @test PolygonArea.disjoint(c) == c

        h = rectangle(0.0, 1/3, 1.0, 2/3)
        v = rectangle(1/3, 0.0, 2/3, 1.0)
        @test area(h ∪ v) ≈ 6/9
        @test area(PolygonArea.disjoint(h ∪ v)) ≈ 5/9

        # A floating point bug: intersection of a circle with a tangeant half plane
        c = circle((0.5, 0.5), 0.4, 60) |> PolygonArea.rotate(π/5, center=(0.5, 0.5))
        r = rectangle(0.45, 0.10, 0.46, 0.11)
        @test PolygonArea.area(r ∩ c) ≈ PolygonArea.area(c ∩ r)

        # 
        horizontal_rectangle = PolygonArea.rectangle((0.4, 0.2), (0.6, 0.8))
        vertical_rectangle = PolygonArea.rectangle((0.2, 0.4), (0.8, 0.6))
        cross = horizontal_rectangle ∪ vertical_rectangle
        circ = PolygonArea.circle(0.5, 0.5, 0.35, 100)
        diff = circ \ cross
        @test area(diff) ≈ area(circ) - area(PolygonArea.disjoint(cross))
    end

    @testset "generic programming" begin
        using Unitful: m
        @test area(PolygonArea.ConvexPolygon([(1m, 0m), (1m, 1m), (0m, 1m), (0m, 0m)])) == 1m^2

        @test typeof(area(circle((-1.0m, 0.0m), 2.0m, 6) ∪ circle((1.0m, 0.0m), 2.0m, 6))) == typeof(1.0m*1.0m)

        # Conversion and promotion
        T = Reunion{Intersection{HalfPlane{Float64}}}
        @test convert(T, HalfPlane(1f0, 1f0, 0f0)) isa T
        @test convert(T, rectangle(1f0, 1f0, 2f0, 2f0)) isa T

        @test (HalfPlane(1, 1, 1) ∩ HalfPlane(1f0, 2f0, 3f0)) isa Intersection{HalfPlane{Float32}}
        @test (rectangle(0, 0, 2, 2) ∩ rectangle(1f0, 1f0, 3f0, 3f0)) isa ConvexPolygon{Float32}
    end
end
