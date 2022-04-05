module SpeechAugment

using WAV: wavread
using FFTW: fft, ifft


include("./kits.jl")
include("./addecho.jl")
include("./addnoise.jl")
include("./distort.jl")
include("./drop.jl")
include("./farfield.jl")
include("./speed.jl")
include("./augment.jl")
include("./firfilters.jl")

end
