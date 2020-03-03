
struct HalfPlane <: Surface
    a::Float64
    b::Float64
    c::Float64
end

equation(h::HalfPlane) = (x, y) -> h.a*x + h.b*y + h.c
Base.in(p, h::HalfPlane) = equation(h)(p...) <= 0
Base.in(p, hs::Intersection{HalfPlane}) = all((p in h) for h in hs.hs)
Base.in(p, hs::Reunion{HalfPlane}) = any((p in h) for h in hs.hs)

function corner(h1::HalfPlane, h2::HalfPlane) 
    A = @SMatrix [h1.a h1.b; h2.a h2.b]
    b = @SVector [-h1.c, -h2.c]
    x = A \ b
    return x
end

Base.intersect(h1::HalfPlane, h2::HalfPlane) = Intersection{HalfPlane}([h1, h2])
Base.intersect(h1::Intersection{HalfPlane}, h2::HalfPlane) = Intersection{HalfPlane}([h1.hs..., h2])
Base.intersect(h1::HalfPlane, h2::Intersection{HalfPlane}) = intersect(h2, h1)
Base.intersect(h1::Intersection{HalfPlane}, h2::Intersection{HalfPlane}) = Intersection{HalfPlane}([h1.hs..., h2.hs...])

Base.union(h1::HalfPlane, h2::HalfPlane) = Reunion{HalfPlane}([h1, h2])
Base.union(h1::Reunion{HalfPlane}, h2::HalfPlane) = Reunion{HalfPlane}([h1.hs..., h2])
Base.union(h1::HalfPlane, h2::Reunion{HalfPlane}) = Reunion{HalfPlane}([h1, h2.hs...])
Base.union(h1::Reunion{HalfPlane}, h2::Intersection{HalfPlane}) = Reunion{HalfPlane}([h1.hs..., h2.hs...])

invert(h::HalfPlane) = HalfPlane(-h.a, -h.b, -h.c)
invert(hs::Intersection{HalfPlane}) = Reunion{HalfPlane}([invert(h) for h in hs.hs])
invert(hs::Reunion{HalfPlane}) = Intersection{HalfPlane}([invert(h) for h in hs.hs])

area(h::HalfPlane) = Inf
area(h::Reunion{HalfPlane}) = Inf

