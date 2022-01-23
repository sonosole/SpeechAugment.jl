export initSpeedWav
export speedWav


"""
    y = speedWav(wav, k)
change wav's speed. Speedup value ∈ [0.8,1.2] is normal and recommended.
"""
function speedWav(wav::Array, k)
    @assert k > 0
    N = veclen(wav);
    O = N>>1;
    X = fft(wav);
    D = floor(Int, k * O);
    L = D+1+D;
    Z = zeros(Complex{eltype(wav)}, L,1);
    if k >= 1
        Z[1: 1:  O  ] = X[1: 1:  O  ];
        Z[L:-1:L-O+1] = X[N:-1:N-O+1];
    else
        Z[1: 1:  D  ] = X[1: 1:  D  ];
        Z[L:-1:L-D+1] = X[N:-1:N-D+1];
    end
    return real(ifft(Z))
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
