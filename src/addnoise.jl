export initAddNoise


function addNoise(speech::Array{T,2}, noise::Array{T,2}, dB::Number) where T
    Ls = length(speech)
    Ln = length(noise)
    if Ln<Ls
        # noise is shoter, should be repeated
        noise = repeat(noise, div(Ls,Ln)+1)
        Ln = length(noise)
    end
    s = floor(Int,rand()*(Ln-Ls) + 1);   # a random start index
    e = s + Ls - 1;                      # a random end index
    Es = sum(speech.^2);                 # energy of speech
    En = sum(noise[s:e].^2) + eps(T);    # energy of noise
    K  = sqrt(Es/En * 10^(-dB/10));
    speech .+= K * noise[s:e]
    return speech
end


function initAddNoise(path::String, period::Int, dBSpan::NTuple{2,Number})
    counter = 1
    noise = nothing
    dBMin, dBMax = dBSpan
    @assert dBMin <= dBMax
    function addnoise(speech::Array{T,2}) where T
        if counter == 1
            file = rand(readdir(path),1)[1]
            @assert endswith(file, "wav") "$path should only keep *.wav files"
            noise, fs = wavread(joinpath(path, file))
        end # every period we read another noise
        (counter == period) ? (counter=1) : (counter+=1)
        return addNoise(speech, noise, rand()*(dBMax - dBMin) + dBMin)
    end
    return addnoise
end


