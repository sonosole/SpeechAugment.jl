using WAV
using SpeechAugment: farfieldWav

# read a wav file
wav,fs = wavread("xxx.wav")
# simulate far-field effects by auto-gain-ctrl method.
# recommended maxvalue is ∈ [0.5,1.0]
y = farfieldWav(wav, fs; maxvalue=0.6)
