# GENERAL RULES FOR INTERSECTION AND UNIONS

# Intersections of HalfPlanes
intersect(h1::HalfPlane, h2::HalfPlane) = Intersection{HalfPlane}([h1, h2])
intersect(h1::Intersection{HalfPlane}, h2::HalfPlane) = Intersection{HalfPlane}([h1.hs..., h2])
intersect(h1::HalfPlane, h2::Intersection{HalfPlane}) = intersect(h2, h1)
intersect(h1::Intersection{HalfPlane}, h2::Intersection{HalfPlane}) = Intersection{HalfPlane}([h1.hs..., h2.hs...])

intersect(h1::T, h2::Reunion{T}) where T <: Surface = Reunion{T}([h1 ∩ h for h in h2.hs])
intersect(h1::Reunion{T}, h2::T) where T <: Surface = Reunion{T}([h ∩ h2 for h in h1.hs])
intersect(h1::Reunion{T}, h2::Reunion{T}) where T <: Surface = Reunion{T}([hi ∩ hj for hi in h1.hs for hj in h2.hs])

in(p::Point, hs::Intersection) = all((p in h) for h in hs.hs)
invert(hs::Intersection) = Reunion{HalfPlane}([invert(h) for h in hs.hs])

# Union of HalfPlanes
union(h1::T, h2::T) where T <: Surface = Reunion{T}([h1, h2])

union(h1::T, h2::Intersection{T}) where T <: Surface = Reunion{Surface}([h1, h2])
union(h1::Intersection{T}, h2::T) where T <: Surface = Reunion{Surface}([h1, h2])

union(h1::Reunion{T}, h2::T) where T <: Surface = Reunion{T}([h1.hs..., h2])
union(h1::T, h2::Reunion{T}) where T <: Surface = Reunion{T}([h1, h2.hs...])
union(h1::Reunion{T}, h2::Reunion{T}) where T <: Surface= Reunion{T}([h1.hs..., h2.hs...])

in(p::Point, hs::Reunion) = any((p in h) for h in hs.hs)
invert(hs::Reunion) = Intersection{HalfPlane}([invert(h) for h in hs.hs])

area(h::Reunion{HalfPlane}) = Inf
