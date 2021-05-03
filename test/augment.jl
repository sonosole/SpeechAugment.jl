# this is an example of how to augment Wavs
using WAV
using SpeechAugment


##------------------------------------##
##---------- exmaple one -------------##
##------------------------------------##

# 1. read a wav file as a speech example
batchsize = 8;
data,fs = wavread("/home/xxx/ASpeechExample.wav");

# 2. init all the augmentation functions you want
echo = initAddEcho(fs, (0.05,0.4), (3.0,3.2,2.5,3.5,2.0,3.0));
noise = initAddNoise("XXPathFullOfNoiseWAVs", 2, (5,15));
clip = initClipWav((0.5,2.0));
drop = initDropWav(fs, (0.09,0.15));
far = initFarfieldWav(fs, (0.5,0.9));
speed = initSpeedWav((0.8,1.2));

# 3. make a function list
fnlist = [echo noise clip drop far speed];

# 4. augment one wav into #batchSize audios
wavlist = augmentWav(fnlist, data, batchsize)
for i = 1:8
    wavwrite(wavlist[i], "$i$i.wav",Fs=16000,nbits=32)
end



##------------------------------------##
##---------- exmaple two -------------##
##------------------------------------##

# 1. prepare #batchSize audios
wavs = Vector(undef, batchsize);
for i = 1:batchsize
    wavs[i] = copy(data)
end
# 2. augment #batchSize audios
wavs = augmentWavs(fnlist, wavs)
for i = 1:batchsize
    wavwrite(wavs[i], "A$i.wav",Fs=16000,nbits=32)
end
