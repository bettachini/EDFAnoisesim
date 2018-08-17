function BitsDisc=noisesim(transmitters, DSNRdB, OSNRdB, INPUTFILE)

% cd ~/Documentos/PONs/eccchain/matlab

%% Simulation parameters declaration
  Carrier= struct;	% GENDRIVE parameters struct
  Network= struct;	% DeviceSTR parameters struct
  Gauss= struct;		% SuperGaussian parameters struct
  [Carrier, Gauss, Network]=InputParameters(Carrier, Gauss, Network);


%% Flags and default values
  transmitters= 128;	% Default number of Tx
  Gauss.r_ex= 10;		% Default [dB] Extinction ratio [10~15 Grosz priv. comm. 090210]
  DSNR= 0;
  OSNR= 0;

  Banderas= struct; 
  Banderas.Eye= 0;              % Generates eye diagramme file
  Banderas.LinkVectors= 0;      % Generates intermediates steps files
  Banderas.Pmeans= 0;           % Intermediate mean powers -> stdout

%% Command line options (using getopt)
%{
opt = getopt(3);
  for ind = 1:numel(opt)
    switch ind
      case 1
        
    end
  end
[opt, arg] = getopt(opt, varargin{:});
%}


%% Rx power
  Gauss.r_ex = 10.0^(Gauss.r_ex/ 10.0);			% [1] Extinction ratio
  % (*Gauss).r_ex= 1.1;                                	% TEST
  Gauss.P_0= 2.0* Gauss.P/ (1.0+ Gauss.r_ex);           % [W] '0'
  % printf("P_0[W]= %e\n",Gauss.P_0);                   % TEST
  Gauss.A_0= sqrt( Gauss.P_0 );                         % [sqrt{W} '0' bit amplitude
  float P_1NRZ= Gauss.P_0* Gauss.r_ex;                  % [W] '1' bit power full duty cycle
  % Gauss.P_peak= P_1NRZ/ Carrier.Duty_Cycle;           % [W] duty cycle corrected '1' bit power (square pulse aprox)
  Gauss.P_peak= P_1NRZ;                                 % [W] '1' bit power (square pulse aprox)
  Gauss.A_peak= sqrt( Gauss.P_peak);                    % [sqrt{W}] duty cycle corrected '1' bit amplitude
  % printf("Tx= %i\tDSNR= %e \t OSNR= %e \t r_ex= %e\n",transmitters, DSNR, OSNR, Gauss.r_ex); // TEST

%{
%% Inputs
% Input file
%    InpFile= fopen('~/Documentos/PONs/Reporte/Graphs/AT_1_7.dat','r');
  InpFile= fopen(INPUTFILE,'r');
  InBitString= fread(InpFile,'char');
  fclose(InpFile);


%% parameters noisesim
DSNR= 10^( DSNRdB/ 10);             % Argument: DSNR [dB] -> DSNR [1]
OSNR= 10^( OSNRdB/ 10);             % Argument: OSNR [dB] -> OSNR [1]
%}



Id= BitSlots(Banderas, Carrier, Gauss, Network, OSNR, OSigmaNoise, DSNR, DSigmaNoise, transmitters, RZBit1Gauss, AuxTemp);        % TEST Ith comment


%%%%%%%%%%%%%%%%%%% POR ACA VAMOS %%%%%%%%%%%%%%%%%

%% Input file
  InpFile= fopen(INPUTFILE,'r');
  InBitString= fread(InpFile,'char');
  fclose(InpFile);

  Carrier.N_Bits= size(InBitString,1);
  Carrier.NPtos_Tot= Carrier.NPtos_Bit* Carrier.N_Bits;   % Total # points



%% Main

[RZPulsesTrainTime, RZPulsesTrain, RZBit0, RZBit1Gauss, Pmean, OSigmaNoise]=Bits2Pulses(Carrier, Gauss, InBitString, OSNR, transmitters);


% DETECTOR THRESHOLD
    [Id, DSigmaNoise]= Threshold1(Carrier, RZBit0, RZBit1Gauss, OSigmaNoise, DSNR, Pmean, FAtt);
    
% PULSES -> BITS
    BitsDisc= Pulses2Bits( Carrier, RZPulsesTrain, RZPulsesTrainTime, Id, DSigmaNoise);
    
