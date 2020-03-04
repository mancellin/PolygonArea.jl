using Test
using PolygonArea
using PolygonArea: Point, vertices

unit_rectangle = rectangle(0, 0, 1, 1)
@test Point(0.5, 0.5) in unit_rectangle
@test Point(1.0, 1.0) in unit_rectangle
@test !(Point(1.2, 1.0) in unit_rectangle)
@test Point(0.0, 0.0) in vertices(unit_rectangle)
@test Point(1.0, 0.0) in vertices(unit_rectangle)
@test !(Point(0.5, 0.5) in vertices(unit_rectangle))

top_right_hp = HalfPlane(1, 1, -1.5)
c1 = unit_rectangle ∩ top_right_hp  # Cut the top-right corner
@test Point(0.5, 0.5) in c1
@test !(Point(0.9, 0.9) in c1)

c2 = unit_rectangle ∩ invert(top_right_hp)  # Keep only the top-right corner
@test !(Point(0.5, 0.5) in c2)
@test Point(0.9, 0.9) in c2

@test area(c1) + area(c2) ≈ area(unit_rectangle)
