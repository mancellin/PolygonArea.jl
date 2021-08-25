# HALF-PLANES

"""Half plane of equation ax + by + c <= 0."""
struct HalfPlane{T} <: Surface
    a::T
    b::T
    c::T
end

HalfPlane(a, b, c) = HalfPlane(promote(a, b, c)...)

function HalfPlane{T}(p1::Point{T}, p2::Point{T}, side) where T
    a = - p2[2] + p1[2]
    b = + p2[1] - p1[1]
    c = - a*p1[1] - b*p1[2]
    if side==:right
        HalfPlane{T}(a, b, c)
    else
        HalfPlane{T}(-a, -b, -c)
    end
end
HalfPlane(p1, p2, side::Symbol=:right) = (T = eltype(p1); HalfPlane{T}(Point{T}(p1...), Point{T}(p2...), side))

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

equation(h::HalfPlane) = (x, y) -> h.a*x + h.b*y + h.c
in(p, h::HalfPlane) = equation(h)(p[1], p[2]) <= 0.0
signed_distance(p, h::HalfPlane) = equation(h)(p[1], p[2])/hypot(h.a, h.b)
distance(p, h::HalfPlane) = max(signed_distance(p, h), 0.0)

outward_normal(h::HalfPlane{T}) where T = SVector{2, T}(h.a, h.b)/hypot(h.a, h.b)
angle(h::HalfPlane{T}) where T = mod(atan(h.b, h.a), 2*T(π))

translate(h::HalfPlane, v) = (n = outward_normal(h); HalfPlane(h.a, h.b, h.c - v[1]*n[1] - v[2]*n[2]))
rotate(h::HalfPlane, ϕ; center=Point(0.0, 0.0)) = PolarHalfPlane(signed_distance(center, h), angle(h) + ϕ; center=center)
complement(h::HalfPlane) = HalfPlane(-h.a, -h.b, -h.c)
exchange_x_and_y(h::HalfPlane) = HalfPlane(h.b, h.a, h.c)

function corner_point(h1::HalfPlane{T}, h2::HalfPlane{T}) where T
    idet = one(T) / (h1.a * h2.b - h2.a * h1.b)
    return Point{T}((-h2.b * h1.c + h1.b * h2.c) * idet, (-h1.a * h2.c + h2.a * h1.c) * idet)
end

isempty(h::HalfPlane) = false
area(h::HalfPlane) = Inf

