# HALF-PLANES

"""Half plane of equation ax + by + c <= 0."""
struct HalfPlane <: Surface
    a::Float64
    b::Float64
    c::Float64
end

# POLAR COORDINATES
# The line is defined in polar coordinates around the center (xc, yc).
# The angle θ is the angle of normal vector.
#
#   ┏━━━━━━┓          ┏━━━━━━┓           ┏━━━━━━┓           ┏━━━━━━┓
#   ┃▒▒▒   ┃          ┃▒     ┃           ┃      ┃           ┃     ▒┃
#   ┃▒▒▒   ┃ θ = 0    ┃▒▒    ┃ θ = π/4   ┃      ┃ θ = π/2   ┃    ▒▒┃ θ = 3π/4
#   ┃▒▒▒   ┃          ┃▒▒▒▒  ┃           ┃▒▒▒▒▒▒┃           ┃  ▒▒▒▒┃
#   ┃▒▒▒   ┃          ┃▒▒▒▒▒ ┃           ┃▒▒▒▒▒▒┃           ┃ ▒▒▒▒▒┃
#   ┗━━━━━━┛          ┗━━━━━━┛           ┗━━━━━━┛           ┗━━━━━━┛
#   ┏━━━━━━┓          ┏━━━━━━┓           ┏━━━━━━┓           ┏━━━━━━┓
#   ┃   ▒▒▒┃          ┃ ▒▒▒▒▒┃           ┃▒▒▒▒▒▒┃           ┃▒▒▒▒▒ ┃
#   ┃   ▒▒▒┃ θ = π    ┃  ▒▒▒▒┃ θ = 5π/4  ┃▒▒▒▒▒▒┃ θ = 3π/2  ┃▒▒▒▒  ┃ θ = 7π/4 = -π/4
#   ┃   ▒▒▒┃          ┃    ▒▒┃           ┃      ┃           ┃▒▒    ┃
#   ┃   ▒▒▒┃          ┃     ▒┃           ┃      ┃           ┃▒     ┃
#   ┗━━━━━━┛          ┗━━━━━━┛           ┗━━━━━━┛           ┗━━━━━━┛
PolarHalfPlane(r, θ; center=Point(0.0, 0.0)) = HalfPlane(cos(θ), sin(θ), -cos(θ)*center[1] - sin(θ)*center[2] + r)
PolarHalfPlane(θ; center=Point(0.0, 0.0)) = PolarHalfPlane(0.0, θ; center=center)

isapprox(h1::HalfPlane, h2::HalfPlane; kw...) = all((isapprox(h1.a, h2.a; kw...), isapprox(h1.b, h2.b; kw...), isapprox(h1.c, h2.c; kw...)))
show(io::IO, h::HalfPlane) = print(io, "HalfPlane(", h.a, "x + ", h.b, "y + ", h.c, " ≤ 0)")

equation(h::HalfPlane) = (x, y) -> h.a*x + h.b*y + h.c
signed_distance(p::Point, h::HalfPlane) = equation(h)(p[1], p[2])
distance(p::Point, h::HalfPlane) = abs(equation(h)(p[1], p[2]))
in(p::Point, h::HalfPlane) = equation(h)(p...) <= 0.0

outward_normal(h::HalfPlane) = SVector{2, Float64}(h.a, h.b)
angle(h::HalfPlane) = mod(atan(h.b, h.a), 2π)

translate(h::HalfPlane, v::SVector{2, Float64}) = HalfPlane(h.a, h.b, h.c - v'*outward_normal(h))
rotate(h::HalfPlane, ϕ; center=Point(0.0, 0.0)) = PolarHalfPlane(signed_distance(center, h), angle(h) + ϕ; center=center)
invert(h::HalfPlane) = HalfPlane(-h.a, -h.b, -h.c)
exchange_x_and_y(h::HalfPlane) = HalfPlane(h.b, h.a, h.c)

function corner(h1::HalfPlane, h2::HalfPlane) 
    A = @SMatrix [h1.a h1.b; h2.a h2.b]
    b = @SVector [-h1.c, -h2.c]
    x = A \ b
    return x
end

isempty(h::HalfPlane) = false
area(h::HalfPlane) = Inf

