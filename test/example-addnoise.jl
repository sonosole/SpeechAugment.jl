using WAV
using SpeechAugment: addNoise

dB = 1.0
period = 10
# read a wav file
wav = wavread("xxx.wav")[1]
# init a addnoise function with dir only having noise audios
addnoise = initAddNoise("XXPathFullOfNoiseWAVs", period)
# every period times the addnoise function would change a background noise audio
noisy = addNoise(wav, dB);
