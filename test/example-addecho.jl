using WAV
using SpeechAugment: addEcho

T60 = 0.2
# read a wav file
wav,fs = wavread("xxx.wav")
# add reverberation effect on audio
echowav = addEcho(wav, fs, T60,
                  (3, 4, 2.5),      # room size
                  (1, 2, 1.2),      # sound src
                  (1.6, 2.6, 1.0)); # micphone
