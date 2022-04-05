"""
    lowpass(fc::Real, fs::Real, N::Int; dtype=Float32) -> h::Vector{dtype}
"""
function lowpass(fc::Real, fs::Real, N::Int; dtype::DataType=Float32)
    @assert fc ≤ fs/2 "fc ≤ fs/2, but got fc=$fc, fs=$fs"
    ωc = fc / fs * 2 * π  # normalized cutoff frequency
    h  = zeros(dtype, N)
    m  = (N+1)/2
    for x = 1:N
        x̂ = x - m
        w = 0.5 - 0.5 * cos( 2*π * (x-1)/(N-1) )
        h[x] = sin(ωc * x̂) / (π * x̂) * w
    end
    if mod(N, 2) ≠ 0
        h[div(N+1,2)] = ωc / π
    end
    return h
end


"""
    highpass(fc::Real, fs::Real, N::Int; dtype=Float32) -> h::Vector{dtype}
"""
function highpass(fc::Real, fs::Real, N::Int; dtype::DataType=Float32)
   return lowpass(fs/2, fs, N, dtype=dtype) - lowpass(fc, fs, N, dtype=dtype)
end


"""
    allpass(fs::Real, N::Int; dtype=Float32) -> h::Vector{dtype}
"""
function allpass(fs::Real, N::Int; dtype::DataType=Float32)
    return lowpass(fs/2, fs, N, dtype=dtype)
end


"""
    bandpass(fL::Real, fH::Real, fs::Real, N::Int; dtype=Float32) -> h::Vector{dtype}
"""
function bandpass(fL::Real, fH::Real, fs::Real, N::Int; dtype::DataType=Float32)
    return lowpass(fH, fs, N, dtype=dtype) - lowpass(fL, fs, N, dtype=dtype)
end


"""
    bandstop(fL::Real, fH::Real, fs::Real, N::Int; dtype=Float32) -> h::Vector{dtype}
"""
function bandstop(fL::Real, fH::Real, fs::Real, N::Int; dtype=Float32)
    return allpass(fs, N, dtype=dtype) - bandpass(fL, fH, fs, N, dtype=dtype)
end


export initFIRLowpassWav
export initFIRHighpassWav
export initFIRBandpassWav


"""
    initFIRLowpassWav(fcspan::NTuple{2,Real};
                      winlen::Int=512,
                      nfilters::Int=10,
                      fs::Real=16000,
                      dtype::DataType=Float32) -> lowpasswav::Function

+ `fcspan`: like (7000, 8000) if `fs`=16000
+ `winlen`: FIR filter length
+ `nfilters`: number of lowpass filters
"""
function initFIRLowpassWav(fcspan::NTuple{2,Real};
                           winlen::Int=512,
                           nfilters::Int=10,
                           fs::Real=16000,
                           dtype::DataType=Float32)
    fmin, fmax = fcspan
    @assert fmin <= fmax <= fs
    hs = Vector(undef, nfilters)
    id = 1:nfilters
    for i in id
        fc = rand()*(fmax - fmin) + fmin
        hs[i] = lowpass(fc, fs, winlen, dtype=dtype)
    end
    function lowpasswav(wav::Array)
        k = rand(id)
        return maxconv(wav, hs[k])
    end
    return lowpasswav
end


"""
    initFIRHighpassWav(fcspan::NTuple{2,Real};
                       winlen::Int=512,
                       nfilters::Int=10,
                       fs::Real=16000,
                       dtype::DataType=Float32) -> highpasswav::Function

+ `fcspan`: like (0, 50) if `fs`=16000
+ `winlen`: FIR filter length
+ `nfilters`: number of highpass filters
"""
function initFIRHighpassWav(fcspan::NTuple{2,Real};
                            winlen::Int=512,
                            nfilters::Int=10,
                            fs::Real=16000,
                            dtype::DataType=Float32)
    fmin, fmax = fcspan
    @assert fmin <= fmax <= fs
    hs = Vector(undef, nfilters)
    id = 1:nfilters
    for i in id
        fc = rand()*(fmax - fmin) + fmin
        hs[i] = highpass(fc, fs, winlen, dtype=dtype)
    end
    function highpasswav(wav::Array)
        k = rand(id)
        return maxconv(wav, hs[k])
    end
    return highpasswav
end


"""
    initFIRBandpassWav(fLspan::NTuple{2,Real},
                       fHspan::NTuple{2,Real};
                       winlen::Int=512,
                       nfilters::Int=10,
                       fs::Real=16000,
                       dtype::DataType=Float32) -> highpasswav::Function

+ `fLspan`: like (0, 50)      if `fs`=16000
+ `fHspan`: like (7600, 8000) if `fs`=16000
+ `winlen`: FIR filter length
+ `nfilters`: number of bandpass filters
"""
function initFIRBandpassWav(fLspan::NTuple{2,Real},
                            fHspan::NTuple{2,Real};
                            winlen::Int=512,
                            nfilters::Int=10,
                            fs::Real=16000,
                            dtype::DataType=Float32)
    fLmin, fLmax = fLspan
    fHmin, fHmax = fHspan
    @assert fLmin <= fLmax <= fs
    @assert fHmin <= fHmax <= fs
    hs = Vector(undef, nfilters)
    id = 1:nfilters
    for i in id
        fL = rand()*(fLmax - fLmin) + fLmin
        fH = rand()*(fHmax - fHmin) + fHmin
        hs[i] = bandpass(fL, fH, fs, winlen, dtype=dtype)
    end
    function bandpasswav(wav::Array)
        k = rand(id)
        return maxconv(wav, hs[k])
    end
    return bandpasswav
end
