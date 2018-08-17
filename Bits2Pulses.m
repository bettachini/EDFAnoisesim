function [RZPulsesTrainTime, RZPulsesTrain, RZBit0, RZBit1Gauss, Pmean, OSigmaNoise]=Bits2Pulses(Carrier, gauss, InBitString, OSNR, transmitters)

[RZPulsesTrainTime, RZPulsesTrain, RZBit0, RZBit1Gauss, LOff]=RZPulsesTrainGenerator(Carrier, gauss, InBitString, transmitters);

% OPTICAL NOISE (AWGN)

%   %ADDITIVE WHITE GAUSSIAN NOISE [SANTIAGO'S GENERATOR]
% 
%   SigmaNoise: [V/m*10-3] width of amplitude gaussian distribution A(t) related to mean noise power as follows:
% 
%   white noise autocorrelation = \sigma^2 * delta(t)  [http://en.wikipedia.org/wiki/White_noise]
%   Wiener-Khinchin: \phi(\omega) [Power Spectral Density]= Fourier(white noise autocorrelation )  [http://en.wikipedia.org/wiki/Wiener–Khinchin_theorem]
%   -> \phi(\omega)= \sigma^2 * Fourier(\delta(t))
%   P [Power]= \int d\omega \phi(\omega)  [http://en.wikipedia.org/wiki/Spectral_density]
%   -> P= \sigma^2 * Fourier(\delta(t))
%   gaussian: Fourier(\delta)=\frac{1}{\sqrt(2*\pi)}
%   -> P =\sigma^2
% 
% 
%   SigmaNoise is calculated from SNR assuming the following:
%   SNR=Power_signal/Power_noise  [http://en.wikipedia.org/wiki/Signal-to-noise_ratio]
%   Power_noise=SigmaNoise^2
%   Power_signal= 0.5*(Power_'0bit' + Power_'1bit')  assuming equal number of '1' and '0' bits  [Andres, Nacho]
%   Power_'0bit'= LOff^2, amplitude for bit '0' due to system extinction ratio
%   Power_'1bit'= P1Mean= \frac{1}{(*Carrier).Bit_Slot} \int_0^{(*Carrier).Bit_Slot} dt Pulse1(t)^2  integrated in bit slot
%   OR? Power_'1bit'= \frac{1}{LimSup-LimInf} \int_LimInf^{LimSup} dt Pulse1(t)^2  integrated in detection window
%   -> SigmaNoise=\sqrt(\frac{LOff^2 + P1Mean}{2 SNR})


% mean signal power -> gaussian sigma noise
    Pmean= 0;
    for i= 1: Carrier.NPtos_Bit
        Pmean= Pmean+ RZBit1Gauss(i)* RZBit1Gauss(i);
    end
	Pmean= 0.5* ( (Pmean/ Carrier.NPtos_Bit )+ LOff* LOff);
	OSigmaNoise= sqrt( Pmean/ OSNR);        % amplitude of noise (Agrawal 4.4.11) [Santiago I.]
	% printf("OSNR= %e\tPmean= %e\tOSigmaNoise= %e\n",OSNR ,*Pmean, *OSigmaNoise);		% TEST

  % float ONoiseVector[(*Carrier).NPtos_Tot];
    % GenRuidoRapido(ONoiseVector, OSigmaNoise, Carrier.NPtos_Tot);		% NoiseVector amplitude
  ONoiseVector= wgn(Carrier.NPtos_Tot,1,OSigmaNoise^2,'linear','real');          % MATLAB GAUSSIAN NOISE

  %for(i=0; i<(*Carrier).NPtos_Tot; i++) printf("%.3e\t%.3e\n",PulsesTrainTime[i],RZPulsesTrain[i]);	% TEST
  %for(i=0; i<(*Carrier).NPtos_Tot; i++) printf("%.3e\t\n",(float) NoiseVector[i]);	% TEST
  %WriteFile("ONoiseVector.dat", RZPulsesTrainTime, ONoiseVector, (*Carrier).NPtos_Tot);	% TEST train to file
  %printf("%li\n",(*Carrier).NPtos_Tot);	% TEST

% Noise addition
  for i=1:Carrier.NPtos_Tot
      RZPulsesTrain(i)= RZPulsesTrain(i)+ ONoiseVector(i);		% Noise addition
  end