export initSpeedWav
export speedWav


"""
    speedWav(wav::Matrix, k::Real)
change `wav`'s speed. Speedup value ∈ [0.8,1.2] is normal and recommended. 
`wav` is a `N × C` shaped matrix, where N is the number of samples, C is 
the number of channels. `k` is the timesteps scale factor, e.g.
+ if `k>1`, then the timesteps is longer, the `wav` is slowed down.
+ if `k<1`, then the timesteps is shorter, the `wav` is speeded up.
"""
function speedWav(wav::Matrix{T}, k::Real) where T <: AbstractFloat
    @assert k > 0.0
    N, C = size(wav) # N:samples, C:channels
    O = N >> 1       # midle point
    X = fft(wav, 1)  # channel-wise
    D = floor(Int, k * O)
    L = D + 1 + D
    F = min(D, O)    # valid max frequency
    Z = zeros(Complex{T}, L, C)
    Z[1: 1:  F  ,:] = X[1: 1:  F  ,:]
    Z[L:-1:L-F+1,:] = X[N:-1:N-F+1,:]
    return real(ifft(Z, 1))
end


"""
    initSpeedWav(minspeed::AbstractFloat, maxspeed::AbstractFloat) -> speedwav(wav::Array)
init speed perturbation effect function
+ `minspeed` e.g. 0.8 means 0.8x
+ `maxspeed` e.g. 1.2 menas 1.2x
"""
function initSpeedWav(minspeed::AbstractFloat, maxspeed::AbstractFloat)
    @assert minspeed <= maxspeed
    function speedwav(wav::Array)
        k = rand()*(maxspeed - minspeed) + minspeed
        return speedWav(wav, 1 / k)
    end
    return speedwav
end
