using WAV
using SpeechAugment: clipWav

# degree of distortion
degree = 0.5
# read a wav file
wav = wavread("xxx.wav")[1]
# clip wav to generate distortion effect
y = clipWav(wav, degree)
