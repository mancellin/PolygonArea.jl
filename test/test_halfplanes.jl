using Test
using StaticArrays
using PolygonArea

inferior_hp = HalfPlane(0, 1, 0)
@test (0, -1) in inferior_hp
@test (0, 0) in inferior_hp
@test !((0, 1) in inferior_hp)

right_hp = HalfPlane(-1, 0, 0)
@test (1, 0) in right_hp
@test !((-1, 0) in right_hp)

@test (1, -1) in intersect(inferior_hp, right_hp)
@test (1, -1) in inferior_hp ∩ right_hp
@test !((1, 1) in intersect(inferior_hp, right_hp))
@test (1, 1) in invert(intersect(inferior_hp, right_hp))

@test !((-1, 1) in union(inferior_hp, right_hp))
@test ((1, 1) in union(inferior_hp, right_hp))

@test PolygonArea.corner(inferior_hp, right_hp) == @SVector [0.0, 0.0]
@test PolygonArea.corner(HalfPlane(1, 0, 1), HalfPlane(0, -1, 0.5)) == @SVector [-1.0, 0.5]


