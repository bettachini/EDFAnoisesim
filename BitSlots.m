function [RZBit1Gauss, OSigmaNoise, DSigmaNoise, Id, AuxTemp]=BitSlots(Carrier, Gauss, Network, OSNR, DSNR, transmitters)


%% petit AuxTemp
  AuxTemp= zeros(Carrier.NPtos_Bit,1);
  for i=1: Carrier.NPtos_Bit 
    AuxTemp(i)= Carrier.dt* ( i- 0.5);     % time for one slot
  end

  
%% Pulse amplitude addition over base [RZ]
  AuxAmp= Gauss.A_peak- Gauss.A_0;
  RZBit1Gauss= AuxAmp.* ones(Carrier.NPtos_Bit,1);
  for i=1: Carrier.NPtos_Bit
    RZBit1Gauss(i)= RZBit1Gauss(i)* exp(-0.5* ( ( (AuxTemp(i)- (Gauss.CentrigFactor* Carrier.Bit_Slot) )/ Gauss.T_0_amp) )^ (2* Gauss.m) );     % SuperGaussian
    % printf("RZ1[%li]= %e\n",i,RZBit1Gauss(i) );       % TEST
  end

  
%% Pulse amplitude addition over base [NRZ]
% for i=1:Carrier.NPtos_Bit
%  RZBit1Gauss(i)= Gauss.A_peak;        % Square [NRZ]
% end
% for(i=0; i<(*Carrier).NPtos_Bit; i++) printf("RZ1[%li]= %e\n",i,RZBit1Gauss[i]); % TEST


%% Bit slots test
%   RZBit0= zeros(Carrier.NPtos_Bit,1);   % '0' SLOT AMPLITUDE
%   for i= 1: Carrier.NPtos_Bit
%     RZBit0(i)= Gauss.A_0;               
%   end
%   RZBit1= zeros(Carrier.NPtos_Bit,1);   % '1' SLOT AMPLITUDE [NRZ]
%   for i=1:Carrier.NPtos_Bit 
%     RZBit1(i)= Gauss.A_0+ RZBit1Gauss(i);
%   end
% % Write2Col("Zero.dat", RZBit0, RZBit1Gauss, (*Carrier).NPtos_Bit);  % TEST one & zero to file

%% PmeanVector
  PmeanVector= zeros(2* Carrier.NPtos_Bit);   		% PmeanVector
  auxVector0= transmitters* Gauss.P_0;
  Pmean_sum= 0;
  for i= 1: Carrier.NPtos_Bit
    auxVector1= RZBit1Gauss(i)+ 2* Gauss.A_0;
    auxVector1= auxVector1* RZBit1Gauss(i);
    PmeanVector(i)= auxVector1+ auxVector0;
    PmeanVector(i+ Carrier.NPtos_Bit)= auxVector0;
    Pmean_sum= Pmean_sum+ PmeanVector(i)+ PmeanVector(i+ Carrier.NPtos_Bit);
  end
  Pmean_sum*= Pmean_sum/ (2.0* Carrier.NPtos_Bit );
  if (Banderas.Pmeans== 1)
    printf("Pmean_transmitter[W]= %3e\n",Pmean_sum);             % TEST PMEAN
  end

%% ATTENUATION STAGE Tx -> EDFAout
  aux_Att= Network.FAtt1* Network.EDFAgain;
  aux_Att= aux_Att* aux_Att;
  Pmean_sum= 0;
  for i= 1: 2* Carrier.NPtos_Bit
    PmeanVector(i)= PmeanVector(i)* aux_Att;
    Pmean_sum= Pmean_sum+ PmeanVector(i);
  end
  Pmean_EDFAout= Pmean_sum/ (2.0* Carrier.NPtos_Bit );
  if (Banderas.Pmeans== 1 )
    printf("Pmean_EDFAout= %3e\n",Pmean_EDFAout);               % TEST PMEAN
  end

%% ONoise calculation
  if (OSNR==0)
    OSigmaNoise= Onoise(Network);
  else
    OSigmaNoise= sqrt((Pmean_EDFAout/ OSNR)*(Network.sim_BW/ Network.r_BW ) );	% optical noise amplitude simulation bandwidth [ TIA/EIA-526-19 ]
  end
  % *OSigmaNoise= sqrt( (Pmean_EDFAout/ OSNR)*( 2* (*Network).Ofilt_CutOff/ (*Network).r_BW )  );      // optical noise amplitude optical filter bandwidth
  if (Banderas.Pmeans== 1 )
    printf("OSigmaNoise^2= %3e\n", *OSigmaNoise* *OSigmaNoise);		% TEST
  end
  if (Banderas.Pmeans== 1 )
    printf("OSNR[dB, 0.1nm]= %3e\n", 10* log10((Pmean_EDFAout/ (*OSigmaNoise* *OSigmaNoise) )* ( 1/((*Network).r_BW* (*Carrier).dt ) ) ) );	% TEST
  end
  % printf("1/dt= %3e\n", 1/(*Carrier).dt);            % TEST


%% Optical & Electric IRR filters dummy start
  Zero= zeros(Carrier.NPtos_Bit);
  DummyAux= sqrt(transmitters )* Gauss.A_0* Network.FAtt1* Network.EDFAgain* Network.FAtt2;
  for i= 1: Carrier.NPtos_Bit
    Zero(i)= DummyAux;
  end
  Zero= OpticalFilter(Zero, Carrier.NPtos_Bit);
  DummyAux= DummyAux* DummyAux;          			% Optical: Amplitude -> Power
  DummyAux= DummyAux* Network.M* Network.R;			% Optical Power -> Electrical Current
  for i=0: Carrier.NPtos_Bit
    Zero(i)= DummyAux;
  int SP;
  ElectricalFilter(Zero, (*Carrier).NPtos_Bit, &SP, Network);




%%%%%%%%%%%%%%%%%%% POR ACA VAMOS %%%%%%%%%%%%%%%%%

  
% OSigmaNoise  
  OSigmaNoise= sqrt( (Pmean_EDFAout/ OSNR)* ( 1/ (Network.r_BW* Carrier.dt ) ) );

% ATTENUATION STAGE EDFA output -> Rx
  Pmean_Rxin= Pmean_EDFAout;
  Pmean_Rxin= Pmean_Rxin* Network.FAtt2;
  Pmean_Rxin= Pmean_Rxin* Network.FAtt2;
  
% DSigmaNoise  
  DSigmaNoise= Pmean_Rxin* Network.R* sqrt(1/ DSNR);      % amplitude of noise (Agrawal 4.4.11) [Santiago I.]

% DETECTOR THRESHOLD
  Id= Threshold1(Carrier, RZBit1Gauss, OSigmaNoise, DSigmaNoise, Network, transmitters, Gauss);
