
# Intersections of HalfPlanes
intersect(h1::HalfPlane, h2::HalfPlane) = Intersection{HalfPlane}([h1, h2])
intersect(h1::Intersection{HalfPlane}, h2::HalfPlane) = Intersection{HalfPlane}([h1.hs..., h2])
intersect(h1::HalfPlane, h2::Intersection{HalfPlane}) = intersect(h2, h1)
intersect(h1::Intersection{HalfPlane}, h2::Intersection{HalfPlane}) = Intersection{HalfPlane}([h1.hs..., h2.hs...])

in(p::Point, hs::Intersection) = all((p in h) for h in hs.hs)
invert(hs::Intersection) = Reunion{HalfPlane}([invert(h) for h in hs.hs])

# Union of HalfPlanes
union(h1::HalfPlane, h2::HalfPlane) = Reunion{HalfPlane}([h1, h2])
union(h1::Reunion{HalfPlane}, h2::HalfPlane) = Reunion{HalfPlane}([h1.hs..., h2])
union(h1::HalfPlane, h2::Reunion{HalfPlane}) = Reunion{HalfPlane}([h1, h2.hs...])
union(h1::Reunion{HalfPlane}, h2::Intersection{HalfPlane}) = Reunion{HalfPlane}([h1.hs..., h2.hs...])

in(p::Point, hs::Reunion) = any((p in h) for h in hs.hs)
invert(hs::Reunion) = Intersection{HalfPlane}([invert(h) for h in hs.hs])

area(h::Reunion{HalfPlane}) = Inf
