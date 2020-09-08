
const Point{T} = SVector{2, T}

rotation_matrix(ϕ) = @SMatrix [cos(ϕ) -sin(ϕ); sin(ϕ) cos(ϕ)]

rotate(p::Point, ϕ; center=Point{Float64}(0.0, 0.0)) = (center = Point(center[1], center[2]);
                                                        center + rotation_matrix(ϕ) * (p - center))

translate(p::Point, v) = Point(p[1] + v[1], p[2] + v[2])
