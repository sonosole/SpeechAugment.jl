export augmentWav
export augmentWavs


"""
    augmentWav(fnlist::Array{Function}, wav::Array, batchSize::Int)
augment one audio into #batchSize audios by randomly applying augment functions.
"""
function augmentWav(fnlist::Array{Function}, wav::Array, batchSize::Int)
    wavs = Vector(undef, batchSize)
    funs = rand(fnlist, batchSize)
    for i = 1:batchSize
        wavs[i] = funs[i](copy(wav))
    end
    return wavs
end


"""
    augmentWavs(fnlist::Array{Function}, wavs::Vector{Array})
augment audios by randomly applying augment functions.
"""
function augmentWavs(fnlist::Array{Function}, wavs::Vector)
    batchSize = length(wavs)
    funs = rand(fnlist, batchSize)
    for i = 1:batchSize
        wavs[i] = funs[i](wavs[i])
    end
    return wavs
end
