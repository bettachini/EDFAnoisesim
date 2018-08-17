function [RZPulsesTrain, SamplingPoint]= Link(Carrier, RZPulsesTrain, OSigmaNoise, DSigmaNoise, Network)

for i=1:Carrier.NPtos_Tot
  RZPulsesTrain(i)= RZPulsesTrain(i)* Network.FAtt1;	% ATTENUATION STAGE Tx -> EDFAin
end
% Write1Col("AtEDFAin.dat", RZPulsesTrain, (*Carrier).NPtos_Tot);	% TEST train to file

for i=1:Carrier.NPtos_Tot
  RZPulsesTrain(i)= RZPulsesTrain(i)* Network.EDFAgain;	% EDFA STAGE EDFAin -> EDFAout
end

% OPTICAL NOISE (AWGN)
ONoiseVector= GenRuidoRapido(OSigmaNoise, Carrier.NPtos_Tot);	% NoiseVector amplitude
% Write1Col("ONoiseVector.dat", ONoiseVector, (*Carrier).NPtos_Tot);	% TEST train to file
for i=1:Carrier.NPtos_Tot
  RZPulsesTrain(i)= RZPulsesTrain(i)+ ONoiseVector(i);	% Noise addition
  RZPulsesTrain(i)= RZPulsesTrain(i)* Network.FAtt2;	% ATTENUATION STAGE EDFAout -> Rx
end
% Write1Col("AtEDFAout.dat", RZPulsesTrain, (*Carrier).NPtos_Tot);	% TEST train to file

RZPulsesTrain= OpticalFilter(RZPulsesTrain, Carrier.NPtos_Tot);
% Write1Col("OptFilt.dat", RZPulsesTrain, (*Carrier).NPtos_Tot);	% TEST train to file

% Optical -> Electrical signal (current)
for i=1:Carrier.NPtos_Tot
  RZPulsesTrain(i)= RZPulsesTrain(i)* RZPulsesTrain(i);	% optical amplitude-> optical power
  RZPulsesTrain(i)= RZPulsesTrain(i)* Network.R;	% -> electrical current (detector responsivity R= 1)
end

% 'THERMAL' NOISE AT DETECTOR
DNoiseVector= GenRuidoRapido(DSigmaNoise, Carrier.NPtos_Tot);	% NoiseVector amplitude
for i=1:Carrier.NPtos_Tot
  RZPulsesTrain(i)= RZPulsesTrain(i)+ DNoiseVector(i);	% Noise addition to electrical current signal
end
% Write1Col("DNoiseVector.dat", DNoiseVector, (*Carrier).NPtos_Tot);	% TEST train to file
% printf("DSNR=\t%e\tDSigmaNoise=\t%e\n",DSNR, DSigmaNoise);	% TEST

[RZPulsesTrain, SamplingPoint]= ElectricalFilter(RZPulsesTrain, Carrier.NPtos_Tot, Network);
% Write1Col("ElecFilt.dat", RZPulsesTrain, (*Carrier).NPtos_Tot);	% TEST train to file
