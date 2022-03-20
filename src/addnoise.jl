export initAddNoise
export addNoise


"""
    addNoise(speech::Array, noise::Array, dB::Number)
add `noise` in `speech` according to dB
"""
function addNoise(speech::Array{S}, noise::Array{N}, dB::Real) where {S,N}
    Ls = veclen(speech)
    Ln = veclen(noise)
    if Ln < Ls
        # noise is shoter, should be repeated
        noise = repeat(noise, div(Ls,Ln)+1)
        Ln = veclen(noise)
    end
    s = floor(Int, rand()*(Ln-Ls) + 1);  # a random start index
    e = s + Ls - 1;                      # a random end index
    Es = sum(speech.^2);                 # energy of speech
    En = sum(noise[s:e].^2) + eps(N);    # energy of noise
    K  = sqrt(Es/En * 10^(-dB/10));
    speech .+= K * noise[s:e]
    return speech
end


"""
    initAddNoise(path::String, period::Int, dBSpan::NTuple{2,Number}; dtype=Float32) -> addnoise(speech::Array)
init a adding noise function
+ `path` dir only having noise audios
+ `period` how often the addnoise function would change a background noise audio
+ `dBSpan` e.g. (dBMin, dBMax)
"""
function initAddNoise(path::String, period::Int, dBSpan::NTuple{2,Number}; dtype=Float32)
    counter = 1
    noise = nothing
    FILES = readtype(".wav", path)
    dBMin, dBMax = dBSpan
    @assert dBMin <= dBMax
    function addnoise(speech::Array)
        if counter == 1
            file  = rand(FILES)
            noise = readwav(joinpath(path, file), type=Array{dtype})
        end # every period we read another noise
        (counter == period) ? (counter=1) : (counter+=1)
        return addNoise(speech, noise, rand()*(dBMax - dBMin) + dBMin)
    end
    return addnoise
end


"""
    initAddNoise(::Vector{Tuple{String, AbstractFloat, Tuple{Real,Real}}}) -> addnoise(speech::Array)

init a adding noise function. Input is like:
    [("/path1/noise1/", 0.2, (5,9)),
     ("/path2/noise2/", 0.3, (9,15)),
     ("/path3/noise3/", 0.5, (10,20))]
+ `String` is dir having noise audios
+ `AbstractFloat` is the probability of being chosen
+ `Tuple{Real,Real}` is dB span e.g. (dBMin, dBMax)
"""
function initAddNoise(noiselist::Vector{Tuple{String,Float64,Tuple{T,T}}}; dtype=Float32) where T <: Real
    n = length(noiselist)
    paths = Vector{String}(undef, n)
    probs = Vector{AbstractFloat}(undef, n)
    deciB = Vector{Tuple{Real,Real}}(undef, n)
    order = Vector(undef, n)
    scale = Vector(undef, n)

    for i = 1:n
        paths[i], probs[i], deciB[i] = noiselist[i]
        @assert probs[i] > 0 "probability > 0, but got $(probs[i])"
    end
    probs = probs ./ sum(probs)
    order = sortperm(probs)
    c = 0.0
    for i = 1:n
        scale[i] = probs[order[i]] + c
        c += probs[order[i]]
    end

    filelists = Vector{Vector{String}}(undef, n)
    for i = 1:n
        filelists[i] = readtype(".wav", paths[i])
    end

    function addnoises(speech::Array)
        p = rand()
        for i = 1:n
            if p < scale[i]
                idxchosen = order[i]
                noise = readwav(rand(filelists[idxchosen]), type=Array{dtype})
                dBMin, dBMax = deciB[idxchosen]
                return addNoise(speech, noise, rand()*(dBMax - dBMin) + dBMin)
            end
        end
    end
    return addnoises
end
