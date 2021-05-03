using WAV
using SpeechAugment: dropWav

# read a wav file
wav, fs = wavread("xxx.wav")
# simulate packet loss effects by dropping frames randomly.
# recommended ratio is ∈ [0.0, 0.05]
y = dropWav(wav, fs; ratio=0.1);
