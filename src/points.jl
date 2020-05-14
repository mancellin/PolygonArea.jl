
const Point = SVector{2, Float64}

rotation_matrix(ϕ) = @SMatrix [cos(ϕ) -sin(ϕ); sin(ϕ) cos(ϕ)]

rotate(p::Point, ϕ; center=Point(0.0, 0.0)) = center + rotation_matrix(ϕ) * (p - center)
translate(p::Point, v) = p + v
