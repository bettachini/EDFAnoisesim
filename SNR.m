function SNR

% physical constants
h= 6.626E-34;     % [J s]
c= 299792458;    % [m/s]
q= 1.602E-19;    % [A s]
K_B= 1.381E-23;     % [J/K]

% Network
Carrier_NPtos_Bit= 64;
Lambda_0= 1.550E-6;     % 1500 nm -> [m]
Br= 1E-10;     % 0.1nm -> [m]
Network_r_BW= c* Br/ (Lambda_0* Lambda_0);    % [Hz] 0.1 nm reference -> frequency range
% Network_r_BW;
sim_BW= 6.4E11;     % simulation bandwidth

% Gauss
EDFAgain= 27.0;     % [dB]
Network_EDFAgain= 10.0^(EDFAgain/ 20.0);     % gain in amplitude
Network_Efilt_CutOff= 14;    % [GHz] detector electrical output low-pass filter
Network_Ofilt_CutOff= 17.5;     % [GHz] pre detector optical input bandpass filter
FAtt2= -28;     % [dB]
Network_FAtt2= 10^(FAtt2/ 20);     % [1]

% Noisesim in programme samplings
Pmean_Tx_c1_ex5= 1.091983e-03;
Pmean_EDFAin_c1_ex5= 1.730677e-06;
Pmean_EDFAout_c1_ex5= 8.673933e-04;
Pmean_Rxin_c1_ex5= 1.374726e-06;

Pmean_Tx_c1_ex10= 7.981070e-04;
Pmean_EDFAin_c1_ex10= 1.264915e-06;
Pmean_EDFAout_c1_ex10= 6.339590e-04;
Pmean_Rxin_c1_ex10= 1.004757e-06;

Pmean_Tx_c1_ex15= 6.732573e-04;
Pmean_EDFAin_c1_ex15= 1.067041e-06;
Pmean_EDFAout_c1_ex15= 5.347874e-04;
Pmean_Rxin_c1_ex15= 8.475808e-07;

Pmean_Tx_c1_ex20= 6.266515e-04;
Pmean_EDFAin_c1_ex20= 9.931758e-07;
Pmean_EDFAout_c1_ex20= 4.977670e-04;
Pmean_Rxin_c1_ex20= 7.889075e-07;

Pmean_Tx_c64_ex10= 1.895234e-02;
Pmean_EDFAin_c64_ex10= 3.003744e-05;
Pmean_EDFAout_c64_ex10= 1.505438e-02;
Pmean_Rxin_c64_ex10= 2.385958e-05;

Pmean_Tx_c64_ex15= 6.794641e-03;
Pmean_EDFAin_c64_ex15= 1.076878e-05;
Pmean_EDFAout_c64_ex15= 5.397176e-03;
Pmean_Rxin_c64_ex15= 8.553948e-06;

Pmean_Tx_c128_ex10= 3.739473e-02;
Pmean_EDFAin_c128_ex10= 5.926667e-05;
Pmean_EDFAout_c128_ex10= 2.970370e-02;
Pmean_Rxin_c128_ex10= 4.707718e-05;

Pmean_Tx_c128_ex15= 1.301319e-02;
Pmean_EDFAin_c128_ex15= 2.062452e-05;
Pmean_EDFAout_c128_ex15= 1.033675e-02;
Pmean_Rxin_c128_ex15= 1.638264e-05;

Pmean_Tx_c128_ex20= 4.612423e-03;
Pmean_EDFAin_c128_ex20= 7.310198e-06;
Pmean_EDFAout_c128_ex20= 3.663778e-03;
Pmean_Rxin_c128_ex20= 5.806697e-06;

% OLD noisesim
% Pmean_Tx_c128_ex10= 3.739473e-02;
% Pmean_EDFAin_c128_ex10= 5.926667e-05;
% Pmean_EDFAout_c128_ex10= 2.970370e-02;
% Pmean_Rxin_c128_ex10= 4.707718e-05;

Pmean_EDFAout= Pmean_EDFAout_c1_ex10;
Pmean_Rxin= Pmean_Rxin_c1_ex10;


% OSNR
G= Network_EDFAgain^2;     % 1 EDFA power gain 
n_sp= 3.5;     % [1]
nu= c/Lambda_0;     % [Hz]
S_sp= (G - 1)* n_sp* h* nu;     % [J]
P_N= S_sp* sim_BW;     % [W]
P_ASE= 2* P_N;     % [W]

% Ptotal_EDFAout= Pmean_EDFAout* Carrier_NPtos_Bit;     % Porque?
Ptotal_EDFAout= Pmean_EDFAout;
OSNR_sim_BW= Ptotal_EDFAout/P_ASE;
OSNR_sim_BW_dB= 10* log10(OSNR_sim_BW);
% OSNR_sim_BW), P_ASE)
OSNR_r_BW_dB= OSNR_sim_BW_dB+ 10* log10( (sim_BW/ Network_r_BW));

P_ASE
OSNR_sim_BW
OSNR_sim_BW_dB
OSNR_r_BW_dB


% OSNR theoretical check
SNR_out= G* Ptotal_EDFAout/ (4* S_sp* sim_BW);
% SNR_out)
SNR_out_dB= 10* log10(SNR_out);
SNR_out_dB;


% Shot noise
M= 10;    % [1] APD amplifier gain
F_A= 5.5;     % [1] exceess noise factor APD
R= 1.2;    % [A/W]detector responsivity for 1550 nm
P_in= Pmean_Rxin;
I_d= 1E-8;     % [A]
B_e= 1E9* Network_Efilt_CutOff;     % [Hz] effective noise bandwidth (assumed =) electrical filter cut-off frequency
sigma_shot2= 2* q* M^2* F_A* (R* P_in+ I_d)* B_e;
sigma_shot2


% Shot noise - ASE power incorporated
P_ASE_downstream= P_ASE* Network_FAtt2* Network_FAtt2;
P_ASE_filtered= P_ASE_downstream* (2E9* Network_Ofilt_CutOff/ sim_BW);
sigma_shot_wASE2= 2* q* M^2* F_A* (R*(P_in+P_ASE_filtered)+ I_d)* B_e;
sigma_shot_wASE2


% Thermal noise
T= 298.17;     % [K]
R_L= 50;     % [J/(s A^2)]
sigma_thermal2= 4* K_B* T* B_e/R_L


% DSNR
% sigma_noise2= sigma_thermal2+ sigma_shot2; 	% sin ASE [no cambia casi nada]
sigma_noise2= sigma_thermal2+ sigma_shot_wASE2;

DSNR= (R* M* P_in)^2/ sigma_noise2;
DSNRdB= 10* log10(DSNR);
sigma_noise2
DSNR
DSNRdB


% Comparacion Lema 1997
B_o= 2E9* Network_Ofilt_CutOff;
sigma_S_ASE2= 4* (B_e/ B_o)* M^2* (R^2* P_in* P_ASE_filtered);
sigma_ASE_ASE2= (2* B_o - B_e)* (B_e/ B_o^2)* (M* R* P_ASE_filtered)^2;
% sigma_S_ASE2), sigma_ASE_ASE2), sigma_thermal2+ sigma_shot_wASE2+ sigma_S_ASE2+ sigma_ASE_ASE2);
sigma_noise2_alt= sigma_thermal2+ sigma_shot_wASE2+ sigma_S_ASE2+ sigma_ASE_ASE2;
DSNR_alt= (R* M* P_in)^2/ sigma_noise2_alt;
DSNRdB_alt= 10* log10(DSNR_alt);
DSNR_alt;
DSNRdB_alt;

sigma_S_ASE2
sigma_ASE_ASE2
