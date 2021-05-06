module SpeechAugment

using WAV: wavread
using FFTW: fft, ifft


function veclen(a::Array{T}) where T
    TYPE = typeof(a)
    if TYPE <: Array{T,1}
        return length(a)
    end
    if TYPE <: Array{T,2}
        @assert 1 in size(a)
        return length(a)
    end
end


include("./addecho.jl")
include("./addnoise.jl")
include("./distort.jl")
include("./drop.jl")
include("./farfield.jl")
include("./speed.jl")
include("./augment.jl")

end
