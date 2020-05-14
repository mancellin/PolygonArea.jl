using Test
using PolygonArea
using PolygonArea: PolarHalfPlane, Point, vertices

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

@test Point(0.0, 1.2) in rotate(rectangle(0.0, 0.0, 1.0, 1.0), π/4)
@test Point(0.0, 1.2) in translate(rectangle(0.0, 0.0, 1.0, 1.0), SVector(-0.3, 0.5))

top = PolarHalfPlane(0.0, 3π/2, center=Point(0.5, 0.5))
left = PolarHalfPlane(0.0, 0.0, center=Point(0.5, 0.5))
topleft = top ∩ left
bottomright = invert(top) ∩ invert(left)
mask = topleft ∪ bottomright
unit_rectangle ∩ mask

r1 = rectangle(0, 0, 2, 2)
r2 = rectangle(1, 1, 2, 2)
r3 = rectangle(1.5, 1.5, 2.5, 2.5)
(unit_rectangle ∪ r2) ∩ (r1 ∪ r3)

c = circle(0.0, 0.0, 1.0, 10)
