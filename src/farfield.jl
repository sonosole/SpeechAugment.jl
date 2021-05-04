export initFarfieldWav

"""
    y = farfieldWav(wav::Array, fs::Real=16000.0; maxvalue::Real=0.6, minstep::Real=-0.6)
simulate far-field effects by auto-gain-ctrl method.
"""
function farfieldWav(wav::Array, fs::Real=16000.0; maxvalue::Real=0.6, minstep::Real=-0.6)
    MAX = maximum(abs.(wav)) + 3e-5
    wav .*= 1.0 / MAX;
    minstep  = (-1.0 < minstep < 0.0) ? minstep : -0.6
    maxvalue = (0.0 < maxvalue < 1.0) ? maxvalue : 0.6
    gain   = 1.0
    winlen = floor(Int, 0.016 * fs)
    frames = div(length(wav)-winlen, winlen) + 1
    firstIds = (0:(frames-1)) .* winlen .+ 1       # 帧起始下标
    lasstIds = firstIds .+ (winlen - 1)            # 帧结束下标
    maxvalue = 1 / maxvalue
    for t = 1:frames
        index = firstIds[t]:lasstIds[t];
        frame = wav[index];
        fmax = maximum(abs.(frame));
        step = 1.0 - fmax*maxvalue;
        step = step * abs(step);
        step = max(minstep, min(step, 0.0));
        gain = 0.8*gain + 0.2*(1 + step);
        wav[index] .*= gain * MAX;
    end
    return wav
end


function initFarfieldWav(fs::Real, maxvalueSpan::NTuple{2,Number})
    MinV, MaxV = maxvalueSpan
    @assert MinV <= MaxV
    function farfieldwav(wav::Array{T,2}) where T
        v = rand()*(MaxV - MinV) + MinV
        return farfieldWav(wav, fs, maxvalue=v)
    end
    return farfieldwav
end
