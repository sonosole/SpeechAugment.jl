export initAddEcho
export addEcho


"""
    arcrc(T₆₀::Number, Lᵣ::NTuple{3,Real})

                  β * V
`T₆₀ = ———————————————————————`\n
          - S * ln(1-α) + m₄ * V
where β = 0.160465, m₄ = 0.0104.
V is volume unit m³, S is area unit m²
"""
function arcrc(T₆₀::Real, Lᵣ::NTuple{3,Real})
    # acoustical reflaction coefficient and counts
    if T₆₀>3. T₆₀ = 3.00000 end # max time
    if T₆₀<0. T₆₀ = 0.00625 end # min time
    x,y,z = Lᵣ
    V = x * y * z                 # volume
    S = (x*y + x*z + y*z)*2       # area
    β  = 0.1611                   # 24log(10)/344
    m₄ = 0.0104                   # 4m value
    L  = 4 * V / S                # mean free propagatation length
    α = 1 - exp((m₄ - β/T₆₀)*V/S) # acoustical absorption coefficient
    C = floor(Int, 344 * T₆₀ / L) # reflaction counts
    γ = sqrt(1-α)                 # reflaction coefficient
    return (-γ, C÷6)
end


"""
    y = directconv(x, h)
convolves vectors x and h. The resulting vector is length length(x)+length(h)-1 which
has a O(Lx*Lh) complexity.
"""
function directconv(x::Array, h::Array)
    Lx = veclen(x)
    Lh = veclen(h)
    L  = Lx + Lh - 1
    y  = zeros(eltype(x), L)
    c  = h[end:-1:1]
    # boundary left y[1:Lh-1]
    for i=1:Lh-1
        y[i] = sum(x[1:i] .* h[i:-1:1])
    end
    # middle part y[Lh:Lx]
    for i=Lh:Lx
        y[i] = sum(x[i-Lh+1:i] .* c)
    end
    # right part y[Lx+1:Ly]
    for i=0:Lh-2
        y[L-i] = sum(x[Lx-i:Lx] .* h[Lh:-1:Lh-i])
    end
    return y
end


"""
    y = conv(x::Array, h::Array)
convolves signals x and h. The resulting signal has length (Lx + Lh - 1) which
has nearly O(Lx*Log(Lx)) complexity when Lx>>Lh. This function uses fft to reduce complexity.
"""
function conv(x::Array, h::Array)
    Lx = veclen(x)
    Lh = veclen(h)
    L  = Lx + Lh - 1
    xₑ = zeros(eltype(x), L)
    hₑ = zeros(eltype(h), L)
    xₑ[1:Lx] = x
    hₑ[1:Lh] = h
    return real(ifft( fft(xₑ) .* fft(hₑ) ))
end


"""
    y = maxconv(x::Array, h::Array)
convolves signals x and h. The resulting signal has length max(Lx,Lh) which
has nearly O(Lx*Log(Lx)) complexity when Lx>>Lh. This function uses fft to reduce complexity.
"""
function maxconv(x::Array, h::Array)
    Lx = veclen(x)
    Lh = veclen(h)
    if Lx ≥ Lh
        H = zeros(eltype(h), Lx)
        copyto!(H, h)
        return real(ifft( fft(x) .* fft(H) ))
    else
        X = zeros(eltype(x), Lh)
        copyto!(X, x)
        return real(ifft( fft(X) .* fft(h) ))
    end
end


"""
    y = rir(fs::Real, T60::Real, room::NTuple{3,Real}, src::NTuple{3,Real}, mic::NTuple{3,Real}; dtype=Float32)
Generate room impulse response.
"""
function rir(fs::Real, T60::Real, room::NTuple{3,Real}, src::NTuple{3,Real}, mic::NTuple{3,Real}; dtype=Float32)
    γ, C = arcrc(T60, room)
    N = 2*C + 1
    L = floor(Int, fs*T60)
    x = zeros(dtype, N)
    y = zeros(dtype, N)
    z = zeros(dtype, N)
    h = zeros(dtype, L)
    xr, yr, zr = room  # room's size in meters
    xs, ys, zs = src   # source's coordinates in meters
    xm, ym, zm = mic   # micphone's coordinates in meters
    for i = -C:1:C
        if i&1==1 # odd number
            x[i+C+1] = xs + i*xr - xm;
            y[i+C+1] = ys + i*yr - ym;
            z[i+C+1] = zs + i*zr - zm;
        else # even number
            x[i+C+1] = -xs + (i+1)*xr - xm;
            y[i+C+1] = -ys + (i+1)*yr - ym;
            z[i+C+1] = -zs + (i+1)*zr - zm;
        end
    end
    maxi = 0
    λ⁻¹  = fs / 344.0
    for i = -C:1:C
        for j = -C:1:C
            for k = -C:1:C
                d = sqrt( x[i+C+1]^2 + y[j+C+1]^2 + z[k+C+1]^2 )
                n = floor(Int, d * λ⁻¹)
                if n>L;  continue; end
                if n==0; continue; end
                if maxi<n; maxi=n; end
                m = abs(i) + abs(j) + abs(k)
                h[n] += γ^m / d
            end
        end
    end
    return h[1:maxi]
end


"""
    y = addEcho(wav::Array, fs::Real, T60::Real,
                room::NTuple{3,Real},
                src::NTuple{3,Real},
                mic::NTuple{3,Real}; by="maxlen", dtype=Float32)
Generate impulse response function online, and add reverberation effect to wav.
## Arguments
- `wav`: sound samples
- `fs`: sound's sampling rate
- `T60`: effective reverberation time
- `room`: room's size in meters, e.g., (3, 4, 2.5)
- `src`: source's coordinates in meters, e.g., (1, 2, 1.2)
- `mic`: micphone's coordinates in meters, e.g., (1.6, 2.6, 1.0)
"""
function addEcho(wav::Array, fs::Real, T60::Real,
                 room::NTuple{3,Real},
                 src ::NTuple{3,Real},
                 mic ::NTuple{3,Real}; by="maxlen", dtype=Float32)

    return ifelse(by=="maxlen",
    maxconv(wav, rir(fs, T60, room, src, mic, dtype=dtype)),
    conv(wav, rir(fs, T60, room, src, mic, dtype=dtype)))
end


function initAddEcho(path::String, period::Int; dtype=Float32)
    counter = 1
    h = nothing
    FILES = readtype(".wav", path)
    function addecho(speech::Array)
        if counter == 1
            file = rand(FILES)
            h = readwav(joinpath(path, file), type=Array{dtype})
        end # read another Room Impulse Response every period
        (counter == period) ? (counter=1) : (counter+=1)
        return conv(speech, h)
    end
    return addecho
end


"""
    initAddEcho(fs::Real, T₆₀Span::NTuple{2,Real}, roomSpan::NTuple{6,Real}; dtype=Float32) -> addecho(wav::Array)
init reverberation effect function.
+ `fs` sampling rate
+ `T₆₀Span` T₆₀ range e.g. (0.05, 0.5)
+ `roomSpan`room size e.g. (MinL, MaxL, MinW, MaxW, MinH, MaxH)
"""
function initAddEcho(fs::Real, T₆₀Span::NTuple{2,Real}, roomSpan::NTuple{6,Real}; by="maxlen", dtype=Float32)
    MinT₆₀, MaxT₆₀ = T₆₀Span
    MinL, MaxL, MinW, MaxW, MinH, MaxH = roomSpan
    @assert MinT₆₀ <= MaxT₆₀
    @assert MinL <= MaxL
    @assert MinW <= MaxW
    @assert MinH <= MaxH
    function addecho(wav::Array)
        T₆₀ = rand()*(MaxT₆₀ - MinT₆₀) + MinT₆₀
        Lx  = rand()*(MaxL - MinL) + MinL
        Ly  = rand()*(MaxW - MinW) + MinW
        Lz  = rand()*(MaxH - MinH) + MinH
        room = (Lx, Ly, Lz)
        src  = (rand()*Lx, rand()*Ly, rand()*Lz)
        mic  = (rand()*Lx, rand()*Ly, rand()*Lz)
        return ifelse(by=="maxlen",
        maxconv(wav, rir(fs, T60, room, src, mic, dtype=dtype)),
        conv(wav, rir(fs, T60, room, src, mic, dtype=dtype)))
    end
    return addecho
end
