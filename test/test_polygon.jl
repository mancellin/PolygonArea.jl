using Test
using PolygonArea

s = rectangle(0, 0, 1, 1)
@test (0.5, 0.5) in s
@test (1.0, 1.0) in s

c = s ∩ HalfPlane(1, 0, -0.2)
#= @test (0, 0) in c =#
#= @test !((0.5, 0.5) in c) =#

area(s)
