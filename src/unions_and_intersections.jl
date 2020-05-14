# GENERAL RULES FOR INTERSECTION AND UNIONS

import Base.in, Base.union, Base.intersect, Base.convert, Base.promote_rule
using Base.Iterators: product

struct Intersection{T <: Surface} <: Surface
    content::Vector{T}

    function Intersection{T}(content) where T
        content = unique(content)
        if any(isempty(h) for h in content)
            return new([])
        else
            return new(content)
        end
    end
end

struct Reunion{T <: Surface} <: Surface
    content::Vector{T}

    Reunion{T}(content) where T = new(filter(!isempty, unique(content)))
end

# Generic fonctions

in(p::Point, i::Intersection) = all((p in h) for h in i.content)
in(p::Point, u::Reunion) = any((p in h) for h in u.content)

isempty(i::Intersection) = any(isempty(h) for h in i.content)
isempty(u::Reunion) = all(isempty(h) for h in u.content)

invert(i::Intersection) = foldl(union, (invert(h) for h in i.content))
invert(u::Reunion) = foldl(intersect, (invert(h) for h in u.content))

# Union and intersection of half planes

convert(::Type{Intersection{HalfPlane}}, h::HalfPlane) = Intersection{HalfPlane}([h])
convert(::Type{Reunion{HalfPlane}}, h::HalfPlane) = Reunion{HalfPlane}([h])
convert(::Type{Reunion{Intersection{HalfPlane}}}, h::HalfPlane) = Reunion{Intersection{HalfPlane}}([Intersection{HalfPlane}([h])])
convert(::Type{Reunion{Intersection{HalfPlane}}}, i::Intersection{HalfPlane}) = Reunion{Intersection{HalfPlane}}([i])
convert(::Type{Reunion{Intersection{HalfPlane}}}, u::Reunion{HalfPlane}) = Reunion{Intersection{HalfPlane}}([Intersection{HalfPlane}([h]) for h in u.content])

promote_rule(::Type{HalfPlane}, ::Type{Intersection{HalfPlane}}) = Intersection{HalfPlane}
promote_rule(::Type{HalfPlane}, ::Type{Reunion{HalfPlane}}) = Reunion{HalfPlane}
promote_rule(::Type{HalfPlane}, ::Type{Reunion{Intersection{HalfPlane}}}) = Reunion{Intersection{HalfPlane}}
promote_rule(::Type{Intersection{HalfPlane}}, ::Type{Reunion{Intersection{HalfPlane}}}) = Reunion{Intersection{HalfPlane}}
promote_rule(::Type{Reunion{HalfPlane}}, ::Type{Reunion{Intersection{HalfPlane}}}) = Reunion{Intersection{HalfPlane}}
promote_rule(::Type{Reunion{HalfPlane}}, ::Type{Intersection{HalfPlane}}) = Reunion{Intersection{HalfPlane}}

union(s1::Surface, s2::Surface) = union(promote(s1, s2)...)
intersect(s1::Surface, s2::Surface) = intersect(promote(s1, s2)...)

union(h1::HalfPlane, h2::HalfPlane) = Reunion{HalfPlane}([h1, h2])
union(u1::Reunion{HalfPlane}, u2::Reunion{HalfPlane}) = Reunion{HalfPlane}(vcat(u1.content, u2.content))
union(i1::Intersection{HalfPlane}, i2::Intersection{HalfPlane}) = Reunion{Intersection{HalfPlane}}([i1, i2])
union(ui1::Reunion{Intersection{HalfPlane}}, ui2::Reunion{Intersection{HalfPlane}}) = Reunion{Intersection{HalfPlane}}(vcat(ui1.content, ui2.content))

intersect(h1::HalfPlane, h2::HalfPlane) = Intersection{HalfPlane}([h1, h2])
intersect(i1::Intersection{HalfPlane}, i2::Intersection{HalfPlane}) = Intersection{HalfPlane}(vcat(i1.content, i2.content))
intersect(u1::Reunion{HalfPlane}, u2::Reunion{HalfPlane}) = intersect(convert(Reunion{Intersection{HalfPlane}}, u1), convert(Reunion{Intersection{HalfPlane}}, u2))
function intersect(ui1::Reunion{Intersection{HalfPlane}}, ui2::Reunion{Intersection{HalfPlane}})
    inters = []
    for (i1, i2) in product(ui1.content, ui2.content)
        push!(inters, Intersection{HalfPlane}(vcat(i1.content, i2.content)))
    end
    return Reunion{Intersection{HalfPlane}}(inters)
end

rotate(u::Reunion{T}, ϕ; kw...) where T = Reunion{T}(map(x -> rotate(x, ϕ; kw...), u.content))
rotate(i::Intersection{T}, ϕ; kw...) where T = Intersection{T}(map(x -> rotate(x, ϕ; kw...), i.content))

translate(u::Reunion{T}, v) where T = Reunion{T}(map(x -> translate(x, v), u.content))
translate(i::Intersection{T}, v) where T = Intersection{T}(map(x -> translate(x, v), i.content))
