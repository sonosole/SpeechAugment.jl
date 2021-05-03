export initDropWav

"""
    y = dropWav(wav::Array, fs::Real=16000.0; ratio::Real=0.05)
droping frames to simulate network packet loss.
"""
function dropWav(wav::Array, fs::Real=16000.0; ratio::Real=0.05)
    ZERO = eltype(wav)(0.0)
    winlen = floor(Int, 0.016 * fs)                # 0.016毫秒一帧
    frames = div(length(wav)-winlen, winlen) + 1   # 帧数
    firstIds = (0:(frames-1)) .* winlen .+ 1       # 帧起始下标
    lasstIds = firstIds .+ (winlen - 1)            # 帧结束下标
    for t = 1:frames
        if rand()<ratio
            wav[firstIds[t]:lasstIds[t]] .= ZERO;
        end
    end
    return wav
end


function initDropWav(fs::Real, ratioSpan::NTuple{2,Number})
    MinR, MaxR = ratioSpan
    @assert MinR <= MaxR
    function dropwav(wav::Array{T,2}) where T
        ratio = rand()*(MaxR - MinR) + MinR
        return dropWav(wav, fs; ratio=ratio)
    end
    return dropwav
end
