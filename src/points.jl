
const Point{T} = SVector{2, T}

rotation_matrix(ϕ) = @SMatrix [cos(ϕ) -sin(ϕ); sin(ϕ) cos(ϕ)]

rotate(p::Point, ϕ; center=Point{Float64}(0.0, 0.0)) = (center = Point(center[1], center[2]);
                                                        center + rotation_matrix(ϕ) * (p - center))

translate(p::Point, v) = Point(p[1] + v[1], p[2] + v[2])

scale(x::Point, λ::AbstractVector; center=Point(0.0, 0.0)) where T = λ.*(x.-center) .+ center
scale(x::Point, λ::Real; center=Point(0.0, 0.0)) where T = scale(x, SVector{2}(λ, λ); center)
