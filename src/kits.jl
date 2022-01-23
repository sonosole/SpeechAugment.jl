function veclen(a::Array{T}) where T
    TYPE = typeof(a)
    if TYPE <: Array{T,1}
        return length(a)
    end
    if TYPE <: Array{T,2}
        @assert 1 in size(a)
        return length(a)
    end
end


function readtype(suffix::String, path::String)
    # read all files having a certain suffix like txt in a path
    n = length(suffix) - 1
    typefiles = Vector{String}(undef, 0)
    ABSPATH   = abspath(path)
    for file in readdir(path)
        if suffix == file[end-n:end]
            push!(typefiles, ABSPATH * file)
        end
    end
    return typefiles
end
