export initClipWav
export clipWav


"""
    y = clipWav(x::Array, a)
use clipping to create distortion effects
"""
function clipWav(x::Array, a)
    s = (0.4 + 0.1 * rand());
    c = (s + 1) / 2;
    k = (1 - s) / (s - c)^2;
    x .*= a/(maximum(abs.(x)) + 3e-5);
    L = veclen(x)
    for t = 1:L
        if c < x[t]
            x[t] = 1.0;
        elseif s < x[t] <= c
            x[t] = -k * ( x[t] - c )^2 + 1;
        elseif -c <= x[t] < -s
            x[t] =  k * ( x[t] + c )^2 - 1;
        elseif x[t] < -c
            x[t] = -1.0;
        end
    end
    return x
end


"""
    initClipWav(clipMin::AbstractFloat, clipMax::AbstractFloat) -> clipwav(wav::Array)
init distortion effect function
+ `clipMin` e.g. 0.5
+ `clipMax` e.g. 2.0
"""
function initClipWav(clipMin::AbstractFloat, clipMax::AbstractFloat)
    @assert 0 < clipMin <= clipMax
    function clipwav(wav::Array)
        return clipWav(wav, rand()*(clipMax - clipMin) + clipMin)
    end
    return clipwav
end
