export initAddNoise
export addNoise


"""
    addNoise(speech::Array, noise::Array, dB::Number)
add `noise` in `speech` according to dB
"""
function addNoise(speech::Array{T}, noise::Array{T}, dB::Number) where T
    Ls = veclen(speech)
    Ln = veclen(noise)
    if Ln<Ls
        # noise is shoter, should be repeated
        noise = repeat(noise, div(Ls,Ln)+1)
        Ln = veclen(noise)
    end
    s = floor(Int,rand()*(Ln-Ls) + 1);   # a random start index
    e = s + Ls - 1;                      # a random end index
    Es = sum(speech.^2);                 # energy of speech
    En = sum(noise[s:e].^2) + eps(T);    # energy of noise
    K  = sqrt(Es/En * 10^(-dB/10));
    speech .+= K * noise[s:e]
    return speech
end


"""
    initAddNoise(path::String, period::Int, dBSpan::NTuple{2,Number}) -> addnoise(speech::Array)
init a adding noise function
+ `path` dir only having noise audios
+ `period` how often the addnoise function would change a background noise audio
+ `dBSpan` e.g. (dBMin, dBMax)
"""
function initAddNoise(path::String, period::Int, dBSpan::NTuple{2,Number})
    counter = 1
    noise = nothing
    FILES = readdir(path)
    dBMin, dBMax = dBSpan
    @assert dBMin <= dBMax
    function addnoise(speech::Array)
        if counter == 1
            file = rand(FILES,1)[1]
            @assert endswith(file, "wav") "$path should only keep *.wav files"
            noise, fs = wavread(joinpath(path, file))
        end # every period we read another noise
        (counter == period) ? (counter=1) : (counter+=1)
        return addNoise(speech, noise, rand()*(dBMax - dBMin) + dBMin)
    end
    return addnoise
end
