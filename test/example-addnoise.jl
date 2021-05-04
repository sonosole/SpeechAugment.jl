using WAV
using SpeechAugment

dB = (5.0, 15.0)
period = 10
# read a wav file
wav = wavread("xxx.wav")[1]
# init a addnoise function with dir only having noise audios
addnoise = initAddNoise("XXPathFullOfNoiseWAVs", period, dB)
# every period times the addnoise function would change a background noise audio
noisy = addnoise(wav);
