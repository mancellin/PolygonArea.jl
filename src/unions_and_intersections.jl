# GENERAL RULES FOR INTERSECTION AND UNIONS

using Base.Iterators: product

struct Intersection{T <: Surface} <: Surface
    content::Vector{T}

    # function Intersection{T}(content) where T
    #     content = unique(content)
    #     if any(isempty(h) for h in content)
    #         return new([])
    #     else
    #         return new(content)
    #     end
    # end
end

==(i1::Intersection, i2::Intersection) = all(h1 == h2 for (h1, h2) in zip(i1.content, i2.content))

struct Reunion{T <: Surface} <: Surface
    content::Vector{T}

    Reunion{T}(content) where T = new(filter(!isempty, unique(content)))
end

# Generic fonctions

in(p, i::Intersection) = all((p in h) for h in i.content)
in(p, u::Reunion) = any((p in h) for h in u.content)

isempty(i::Intersection) = any(isempty(h) for h in i.content)
isempty(u::Reunion) = all(isempty(h) for h in u.content)

complement(i::Intersection) = foldl(union, (complement(h) for h in i.content))
complement(u::Reunion) = foldl(intersect, (complement(h) for h in u.content))

\(c1::Surface, c2::Surface) = c1 ∩ complement(c2)
\(c1::Surface, u2::Reunion) = foldl(\, u2.content, init=c1)

# Union and intersection of half planes

convert(::Type{Intersection{HalfPlane{T}}}, h::HalfPlane{T}) where T = Intersection{HalfPlane{T}}([h])
convert(::Type{Reunion{HalfPlane{T}}}, h::HalfPlane{T}) where T = Reunion{HalfPlane{T}}([h])
convert(::Type{Reunion{Intersection{HalfPlane{T}}}}, h::HalfPlane{T}) where T = Reunion{Intersection{HalfPlane{T}}}([Intersection{HalfPlane{T}}([h])])
convert(::Type{Reunion{Intersection{HalfPlane{T}}}}, i::Intersection{HalfPlane{T}}) where T = Reunion{Intersection{HalfPlane{T}}}([i])
convert(::Type{Reunion{Intersection{HalfPlane{T}}}}, u::Reunion{HalfPlane{T}}) where T = Reunion{Intersection{HalfPlane{T}}}([Intersection{HalfPlane{T}}([h]) for h in u.content])

promote_rule(::Type{HalfPlane{T}}, ::Type{Intersection{HalfPlane{T}}}) where T = Intersection{HalfPlane{T}}
promote_rule(::Type{HalfPlane{T}}, ::Type{Reunion{HalfPlane{T}}}) where T = Reunion{HalfPlane{T}}
promote_rule(::Type{HalfPlane{T}}, ::Type{Reunion{Intersection{HalfPlane{T}}}}) where T = Reunion{Intersection{HalfPlane{T}}}
promote_rule(::Type{Intersection{HalfPlane{T}}}, ::Type{Reunion{Intersection{HalfPlane{T}}}}) where T = Reunion{Intersection{HalfPlane{T}}}
promote_rule(::Type{Reunion{HalfPlane{T}}}, ::Type{Reunion{Intersection{HalfPlane{T}}}}) where T = Reunion{Intersection{HalfPlane{T}}}
promote_rule(::Type{Reunion{HalfPlane{T}}}, ::Type{Intersection{HalfPlane{T}}}) where T = Reunion{Intersection{HalfPlane{T}}}

union(s1::Surface, s2::Surface) = union(promote(s1, s2)...)
intersect(s1::Surface, s2::Surface) = intersect(promote(s1, s2)...)

union(h1::HalfPlane{T}, h2::HalfPlane{T}) where T = Reunion{HalfPlane{T}}([h1, h2])
union(u1::Reunion{HalfPlane{T}}, u2::Reunion{HalfPlane{T}}) where T = Reunion{HalfPlane{T}}(vcat(u1.content, u2.content))
union(i1::Intersection{HalfPlane{T}}, i2::Intersection{HalfPlane{T}}) where T = Reunion{Intersection{HalfPlane{T}}}([i1, i2])
union(ui1::Reunion{Intersection{HalfPlane{T}}}, ui2::Reunion{Intersection{HalfPlane{T}}}) where T = Reunion{Intersection{HalfPlane{T}}}(vcat(ui1.content, ui2.content))

intersect(h1::HalfPlane{T}, h2::HalfPlane{T}) where T = Intersection{HalfPlane{T}}([h1, h2])
intersect(i1::Intersection{HalfPlane{T}}, i2::Intersection{HalfPlane{T}}) where T = Intersection{HalfPlane{T}}(vcat(i1.content, i2.content))
intersect(u1::Reunion{HalfPlane{T}}, u2::Reunion{HalfPlane{T}}) where T = intersect(convert(Reunion{Intersection{HalfPlane{T}}}, u1), convert(Reunion{Intersection{HalfPlane{T}}}, u2))
function intersect(ui1::Reunion{Intersection{HalfPlane{T}}}, ui2::Reunion{Intersection{HalfPlane{T}}}) where T
    inters = []
    for (i1, i2) in product(ui1.content, ui2.content)
        push!(inters, Intersection{HalfPlane{T}}(vcat(i1.content, i2.content)))
    end
    return Reunion{Intersection{HalfPlane{T}}}(inters)
end

rotate(u::Reunion{T}, ϕ; kw...) where T = Reunion{T}(map(x -> rotate(x, ϕ; kw...), u.content))
rotate(i::Intersection{T}, ϕ; kw...) where T = Intersection{T}(map(x -> rotate(x, ϕ; kw...), i.content))

translate(u::Reunion{T}, v) where T = Reunion{T}(map(x -> translate(x, v), u.content))
translate(i::Intersection{T}, v) where T = Intersection{T}(map(x -> translate(x, v), i.content))

scale(u::Reunion{T}, λ, center=Point(0.0, 0.0)) where T = Reunion{T}(map(x -> scale(x, λ, center), u.content))
scale(i::Intersection{T}, λ, center=Point(0.0, 0.0)) where T = Intersection{T}(map(x -> scale(x, λ, center), i.content))
