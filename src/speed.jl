export initSpeedWav
export speedWav


"""
    y = speedWav(wav, k)
change wav's speed. Speedup value ∈ [0.8,1.2] is normal and recommended.
"""
function speedWav(wav::Array, k)
    @assert 1.5>=k>=0.5
    N = veclen(wav);
    O = N>>1;
    X = fft(wav);
    D = floor(Int, k * O);
    L = D+1+D;
    Z = zeros(Complex{eltype(wav)}, L,1);
    Z[1: 1:  O  ] = X[1: 1:  O  ];
    Z[L:-1:L-O+1] = X[N:-1:N-O+1];
    return real(ifft(Z))
end


"""
    initSpeedWav(speedSpan::NTuple{2,Number}) -> speedwav(wav::Array)
init speed perturbation effect function
+ `speedSpan` e.g. (0.8, 1.2)
"""
function initSpeedWav(speedSpan::NTuple{2,Number})
    MinSpeed, MaxSpeed = speedSpan
    @assert MinSpeed <= MaxSpeed
    function speedwav(wav::Array)
        return speedWav(wav, rand()*(MaxSpeed - MinSpeed) + MinSpeed)
    end
    return speedwav
end
