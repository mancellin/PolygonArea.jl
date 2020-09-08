using Test
using StaticArrays
using PolygonArea
using PolygonArea: Reunion, Point, vertices, rotate, translate, square

@testset "Polygons" begin

    @testset "creation and contained points" begin
        unit_square = square((0, 0), 1.0)
        @test Point(0.5, 0.5) in unit_square
        @test Point(1.0, 1.0) in unit_square
        @test !(Point(1.2, 1.0) in unit_square)
        @test Point(0.0, 0.0) in vertices(unit_square)
        @test Point(1.0, 0.0) in vertices(unit_square)
        @test !(Point(0.5, 0.5) in vertices(unit_square))
            
        @test unit_square == rectangle(bottom_left=(0, 0), top_right=(1, 1))
        @test unit_square == rectangle(bottom_left=(0, 0), top_right=(1, 1))
        @test unit_square == rectangle((0, 0), (1, 1))

        @test !(PolygonArea.ConvexPolygon([]) == square((1, 1), 1))
    end

    @testset "properties" begin
        @test isempty(PolygonArea.ConvexPolygon([]))

        @test PolygonArea.nb_sides(rectangle((0, 0), (2, 2))) == 4

        @test area(PolygonArea.square((0, 0), 1.0)) == 1.0
        @test area(rectangle((0, 0), (4, 3))) == 12.0
        @test isapprox(area(circle(Point(0, 0), 1.0, 100)), π, atol=1e3)
    end

    @testset "transformations" begin
        @test Point(0.0, 1.2) in rotate(rectangle(0.0, 0.0, 1.0, 1.0), π/4)
        @test Point(0.0, 1.2) in translate(rectangle(0.0, 0.0, 1.0, 1.0), SVector(-0.3, 0.5))
        @test Point(0.0, 1.2) in translate(rectangle(0.0, 0.0, 1.0, 1.0), [-0.3, 0.5])
        @test Point(0.0, 1.2) in translate(rectangle(0.0, 0.0, 1.0, 1.0), (-0.3, 0.5))
    end

    @testset "union and intersection" begin
        unit_square = rectangle(0, 0, 1, 1)
        top_right_hp = HalfPlane(1, 1, -1.5)
        c1 = unit_square ∩ top_right_hp  # Cut the top-right corner
        @test Point(0.5, 0.5) in c1
        @test !(Point(0.9, 0.9) in c1)

        c2 = unit_square ∩ invert(top_right_hp)  # Keep only the top-right corner
        @test !(Point(0.5, 0.5) in c2)
        @test Point(0.9, 0.9) in c2

        @test area(c1) + area(c2) ≈ area(unit_square)

        @test (square((0.0, 0.0), 1.0) |> invert |> typeof) == Reunion{HalfPlane}
        @test area(square((0.0, 0.0), 3.0) \ square((1.0, 1.0), 1.0)) == 8.0

        top = PolarHalfPlane(0.0, 3π/2, center=Point(0.5, 0.5))
        left = PolarHalfPlane(0.0, 0.0, center=Point(0.5, 0.5))
        topleft = top ∩ left
        bottomright = invert(top) ∩ invert(left)
        mask = topleft ∪ bottomright
        unit_square ∩ mask

        r1 = rectangle(0, 0, 2, 2)
        r2 = rectangle(1, 1, 2, 2)
        r3 = rectangle(1.5, 1.5, 2.5, 2.5)
        (unit_square ∪ r2) ∩ (r1 ∪ r3)

        c = circle(0.0, 0.0, 1.0, 10)
        @test PolygonArea.disjoint(c) == c

        h = rectangle(0, 1/3, 1, 2/3)
        v = rectangle(1/3, 0, 2/3, 1)
        @test area(h ∪ v) ≈ 6/9
        @test area(PolygonArea.disjoint(h ∪ v)) ≈ 5/9
    end
end
