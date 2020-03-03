using Test
using PolygonArea

unit_rectangle = rectangle(0, 0, 1, 1)
@test (0.5, 0.5) in unit_rectangle
@test (1.0, 1.0) in unit_rectangle
@test !((1.2, 1.0) in unit_rectangle)
@test PolygonArea.Point(0.0, 0.0) in PolygonArea.vertices(unit_rectangle)
@test PolygonArea.Point(1.0, 0.0) in PolygonArea.vertices(unit_rectangle)
@test !(PolygonArea.Point(0.5, 0.5) in PolygonArea.vertices(unit_rectangle))

top_right_hp = HalfPlane(1, 1, -1.5)
c1 = unit_rectangle ∩ top_right_hp  # Cut the top-right corner
@test (0.5, 0.5) in c1
@test !((0.9, 0.9) in c1)

c2 = unit_rectangle ∩ invert(top_right_hp)  # Keep only the top-right corner
@test !((0.5, 0.5) in c2)
@test (0.9, 0.9) in c2

@test area(c1) + area(c2) ≈ area(unit_rectangle)
