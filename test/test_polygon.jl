using Test
using PolygonArea

s = rectangle(0, 0, 1, 1)
@test (0.5, 0.5) in s
@test (1.0, 1.0) in s

@show PolygonArea.vertices(s)
h = HalfPlane(1, 1, -1.5)
c = s ∩ h  # Cut the top-right corner
@show PolygonArea.vertices(c)

c = s ∩ invert(h)
@show PolygonArea.vertices(c)
#= @test (0, 0) in c =#
#= @test !((0.5, 0.5) in c) =#

#= area(s) =#
