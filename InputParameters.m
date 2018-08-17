function [Carrier, gauss, Network]=InputParameters(Carrier, gauss, Network)

%% GENDRIVE Carrier
  Carrier.NPtos_Bit= 2^6;						% # points for each bit slot
  Carrier.Duty_Cycle= 1.0/3.0;
  Carrier.B= 10E9;							% bit rate [bits/s] (10 Gbits/s)
  Carrier.Bit_Slot= 1/ Carrier.B;                                       % 1/B B: bit rate [s]
  Carrier.dt= Carrier.Bit_Slot/ Carrier.NPtos_Bit;                   	% time step [s]
  %  printf("Bit_Slot= %.3f ps\n",(*Carrier).Bit_Slot*1E12);
  %  printf("Resolucion temporal= %.3f ps\n",(*Carrier).dt*1E12);



%% DeviceSTR Network
  % General
  c= 299792458;                                 % [m/s] light speed
  Lambda_0= 1.55E-6;                            % [m] carrier wavelength
  Network.CentralNu= c/ Lambda_0;               % [Hz] carrier frequency
  Br= 1E-10;                                    % [m] 0.1 nm reference bandwidth
  Network.sim_BW= 1/ (2* Carrier.dt);           % [Hz] simulation bandwidth
  Network.r_BW= c* Br/ (Lambda_0* Lambda_0);  	% [Hz] 0.1 nm reference -> frequency range
  % printf("BW= %e\n",(*Network).r_BW);          % TEST
 
  % Attenuations and amplification
  FAtt1= -2.0 -1.0 -25.0;			% [dB] Tx -> EDFAin 2dB fibre, 1.0dB insertion, 25 dB 128x1 splitter
  Network.FAtt1= 10^(FAtt1/ 20);                % [1] Tx -> EDFAin for amplitude
  FAtt2= -2.0 -1.0 -25.0;                       % [dB] EDFAout -> Rx 2dB fibre, 1.0dB insertion, 25 dB 1x128 splitter
  Network.FAtt2= 10.0^(FAtt2/ 20.0);            % [1] EDFAout -> Rx amplitude
  EDFAgain= 27.0;                               % [dB] Gain at EDFA <fixed approx>
  Network.EDFAgain= 10.0^(EDFAgain/ 20.0);      % [1] Gain at EDFA amplitude
  % printf("FAtt2= %3e\n",(*Network).FAtt2);           // TEST

  %  Photodetector
  Network.M= 10;                                % [1] APD detector amplifier gain
  Network.R= 1.2;                               % [A/W] detector responsivity for 1550 nm

  % Filters
  Network.Efilt_BW= 14;				% [GHz] cut-off freq electrical filter
  Network.Ofilt_BW= 12.5;			% [GHz] cut-off freq optical filter

  % Sampling range
  Network.Range= 4;                                % even numbers -> effective range SP +- SP/2



%% SuperGaussian gauss
  % Tx power
  P= 2.0;					% [dBm] Tx output power < PX2-1541SF >
  gauss.P= pow(10.0, P/ 10.0)/ 1000;            % [W] Tx output power
  % printf("P[W]= %e\n",(*gauss).P);             % TEST

  % Pulse shape
  gauss.m= 4;    		                                % gaussian=1
  gauss.CentringFactor= 0.25;					% 0.25 -> towards bit slot start edge, 0.5 centres pulse
  gauss.FWHM_pow= Carrier.Duty_Cycle* Carrier.Bit_Slot;		% [s] in power (|E|^2)
  gauss.T_0_amp= gauss.FWHM_pow/(2* sqrt(log(2) ) );            % [s]
  % gauss.T_0_amp= 0.25* Carrier.Duty_Cycle* Carrier.Bit_Slot;  % as Duty_Cycle fraction
