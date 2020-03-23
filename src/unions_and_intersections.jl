# GENERAL RULES FOR INTERSECTION AND UNIONS

import Base.union, Base.intersect, Base.convert, Base.promote_rule
using Base.Iterators: product

struct Intersection{T} <: Surface
    hs::Vector{T}

    Intersection{T}(hs) where {T <: Surface} = new(unique(hs))
end

struct Reunion{T} <: Surface
    hs::Vector{T}

    Reunion{T}(hs) where {T <: Surface} = new(unique(hs))
end

convert(::Type{Intersection{HalfPlane}}, h::HalfPlane) = Intersection{HalfPlane}([h])
convert(::Type{Reunion{HalfPlane}}, h::HalfPlane) = Reunion{HalfPlane}([h])
convert(::Type{Reunion{Intersection{HalfPlane}}}, h::HalfPlane) = Reunion{Intersection{HalfPlane}}([Intersection{HalfPlane}([h])])
convert(::Type{Reunion{Intersection{HalfPlane}}}, h::Intersection{HalfPlane}) = Reunion{Intersection{HalfPlane}}([h])
convert(::Type{Reunion{Intersection{HalfPlane}}}, h::Reunion{HalfPlane}) = Reunion{Intersection{HalfPlane}}([Intersection{HalfPlane}([hi]) for hi in h.hs])

promote_rule(::Type{HalfPlane}, ::Type{Intersection{HalfPlane}}) = Intersection{HalfPlane}
promote_rule(::Type{HalfPlane}, ::Type{Reunion{HalfPlane}}) = Reunion{HalfPlane}
promote_rule(::Type{HalfPlane}, ::Type{Reunion{Intersection{HalfPlane}}}) = Reunion{Intersection{HalfPlane}}
promote_rule(::Type{Intersection{HalfPlane}}, ::Type{Reunion{Intersection{HalfPlane}}}) = Reunion{Intersection{HalfPlane}}
promote_rule(::Type{Reunion{HalfPlane}}, ::Type{Reunion{Intersection{HalfPlane}}}) = Reunion{Intersection{HalfPlane}}
promote_rule(::Type{Reunion{HalfPlane}}, ::Type{Intersection{HalfPlane}}) = Reunion{Intersection{HalfPlane}}

union(s1::Surface, s2::Surface) = union(promote(s1, s2)...)
intersect(s1::Surface, s2::Surface) = intersect(promote(s1, s2)...)

union(s1::HalfPlane, s2::HalfPlane) = Reunion{HalfPlane}([s1, s2])
union(s1::Reunion{HalfPlane}, s2::Reunion{HalfPlane}) = Reunion{HalfPlane}(vcat(s1.hs, s2.hs))
union(s1::Intersection{HalfPlane}, s2::Intersection{HalfPlane}) = Reunion{Intersection{HalfPlane}}([s1, s2])
union(s1::Reunion{Intersection{HalfPlane}}, s2::Reunion{Intersection{HalfPlane}}) = Reunion{Intersection{HalfPlane}}(vcat(s1.hs, s2.hs))

intersect(s1::HalfPlane, s2::HalfPlane) = Intersection{HalfPlane}([s1, s2])
intersect(s1::Intersection{HalfPlane}, s2::Intersection{HalfPlane}) = Intersection{HalfPlane}(vcat(s1, s2))
intersect(s1::Reunion{HalfPlane}, s2::Reunion{HalfPlane}) = intersect(convert(Reunion{Intersection{HalfPlane}}, s1), convert(Reunion{Intersection{HalfPlane}}, s2))
function intersect(s1::Reunion{Intersection{HalfPlane}}, s2::Reunion{Intersection{HalfPlane}})
    inters = []
    for (i1, i2) in product(s1.hs, s2.hs)
        push!(inters, Intersection{HalfPlane}(vcat(i1.hs, i2.hs)))
    end
    return Reunion{Intersection{HalfPlane}}(inters)
end

invert(hs::Intersection{HalfPlane}) = Reunion{HalfPlane}([invert(h) for h in hs.hs])
invert(hs::Reunion{HalfPlane}) = Intersection{HalfPlane}([invert(h) for h in hs.hs])
invert(hs::Reunion{Intersection{HalfPlane}}) = foldl(intersect, [invert(h) for h in hs.hs])

in(p::Point, hs::Intersection{T}) where T = all((p in h) for h in hs.hs)
in(p::Point, hs::Reunion{T}) where T = any((p in h) for h in hs.hs)

isempty(hs::Reunion{T}) where T = all(isempty(h) for h in hs.hs)
