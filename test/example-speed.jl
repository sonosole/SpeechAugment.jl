using WAV
using SpeechAugment: speedWav

# speed parameter
maxspeed = 1.2
minspeed = 0.8
# read a wav file
wav = wavread("xxx.wav")[1]
# speedup speech by speed parameter
y = speedWav(wav, rand()*(maxspeed-minspeed) + minspeed)
