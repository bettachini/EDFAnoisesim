function cuad

close all;
clear all;

Carrier.NPtos_Bit= 2^6;
Carrier.B= 10E9;
Carrier.Bit_Slot= 1/ Carrier.B;
Carrier.dt= Carrier.Bit_Slot/ Carrier.NPtos_Bit;

% tren de bits supergaussiano
RZPulsesTrain=load('RZPulsesTrain.dat');

% tren de bits supergaussiano + ruido optico
AtEDFAout=load('AtEDFAout.dat');

% vector frecuencias
Carrier.NPtos_Tot= size(RZPulsesTrain,1);
TimeVector= (1:Carrier.NPtos_Tot)*Carrier.dt;
vGHz2= ( ( -Carrier.NPtos_Tot/ 2 : (Carrier.NPtos_Tot/ 2 )- 1 )/Carrier.NPtos_Tot )'* (1/ Carrier.dt);
vGHz2=vGHz2/ 1E9;


%% 1 bit

% % % vector frecuencias primer bit
% TimeVector_1b= TimeVector(1:Carrier.NPtos_Bit);
% vGHz_1b= ((-Carrier.NPtos_Bit/ 2 : (Carrier.NPtos_Bit/ 2 )- 1 )/Carrier.NPtos_Bit )'* (1/ Carrier.dt);
% vGHz_1b=vGHz_1b/ 1E9;
% 
% % transformada primer bit supergaussiano
% RZPulsesTrain_1b= RZPulsesTrain(1:Carrier.NPtos_Bit);
% RZPulsesTrain_1b_t= fft(RZPulsesTrain_1b);
% RZPulsesTrain_1b_t(1)=0;    % saca componente de continua
% RZPulsesTrain_1b_tP= RZPulsesTrain_1b_t.*conj(RZPulsesTrain_1b_t)/ Carrier.NPtos_Bit;  % -> potencia
% RZPulsesTrain_1b_tP= fftshift(RZPulsesTrain_1b_tP);
% 
% % tren de bits cuadrado
% maxRZPulsesTrain_1b= max(RZPulsesTrain_1b);
% minRZPulsesTrain_1b= min(RZPulsesTrain_1b);
% cuad= minRZPulsesTrain_1b* ones(Carrier.NPtos_Tot,1);
% for i= 1: Carrier.NPtos_Tot/Carrier.NPtos_Bit
%     for j= 1: Carrier.NPtos_Bit/2
%         cuad((i-1)*Carrier.NPtos_Bit+j,1)= maxRZPulsesTrain_1b;
%     end
% end
% 
% % transformada primer bit cuadrado
% cuad_1b= cuad(1:Carrier.NPtos_Bit);
% cuad_1b_t= fft(cuad_1b);
% cuad_1b_t(1)= 0;    % saca componente de continua
% cuad_1b_tP= cuad_1b_t.*conj(cuad_1b_t)/ Carrier.NPtos_Bit;  % -> potencia
% cuad_1b_tP= fftshift(cuad_1b_tP);
% 
% % grafica primer bit
% figure('Name','primer bit: tren / cuadrada');
% plot(TimeVector_1b, cuad_1b,'.-y', TimeVector_1b, RZPulsesTrain_1b,'.-b');
% legend('cuad\_1b', 'RZPulsesTrain\_1b');
% xlabel ('t [s]');
% ylabel ('A [\sqrt{W}]');
%  
% % % grafica transformada primer bit
% figure('Name','Espectro de potencias primer bit: tren / cuadrada');
% semilogy(vGHz_1b, cuad_1b_tP, '.-y', vGHz_1b, RZPulsesTrain_1b_tP, '.-b');
% legend('cuad\_1b', 'RZPulsesTrain\_1b');
% xlabel ('v [GHz]');
% ylabel ('P [W]');


%% tranformadas de tren completo

% % transformada tren cuadrado
% cuad_t= fft(cuad);
% % qf2(1)= 0;    % saca componente de continua
% cuad_tP= cuad_t.*conj(cuad_t)/ Carrier.NPtos_Bit;  % -> potencia
% cuad_tP= fftshift(cuad_tP);

% transformada tren supergaussiano
RZPulsesTrain_t= fft(RZPulsesTrain);
% RZPulsesTrain_t(1)= 0;
RZPulsesTrain_tP= RZPulsesTrain_t.* conj(RZPulsesTrain_t)/ Carrier.NPtos_Tot;  % -> potencia
RZPulsesTrain_tP= fftshift(RZPulsesTrain_tP);

% transformada tren supergaussiano + ruido
AtEDFAout_t= fft(AtEDFAout);
% AtEDFAout_t(1)= 0;
AtEDFAout_tP= AtEDFAout_t.* conj(AtEDFAout_t)/ Carrier.NPtos_Tot;  % -> potencia
AtEDFAout_tP= fftshift(AtEDFAout_tP);


%% grafica tren completo y transformadas
% % grafica tren
% figure;
% plot((1:siz2)* Carrier.dt, q,'.-', (1:siz2)* Carrier.dt, u0,'.-');
% xlabel ('t [s]');
% 
% % grafica transformada tren
% figure;
% semilogy(vGHz2,qf2/max(qf2),'.-', vGHz2,sf2/max(sf2),'.-');
% xlabel ('v [GHz]');
% ylabel ('arb');


%% filtro cuadrado

SqFilt_CutOff= 12.5;
AtEDFAout_SqFilt_t= zeros(Carrier.NPtos_Tot,1);
% oGAIN= 3.419013222e+06;
% oGAIN= sqrt(oGAIN);
% oGAIN= oGAIN* oGAIN;
AtEDFAout_t_sh= fftshift(AtEDFAout_t);
for i= 1: Carrier.NPtos_Tot
  if abs(vGHz2(i))<SqFilt_CutOff
%      Fout_SF(i)= Fin(i)/ sqrt(oGAIN* (1- abs(vGHz(i)/ SqFilt_CutOff) ) );
%      Fout_SF(i)= Fin(i)/ (sqrt(oGAIN)* (abs(vGHz(i)/ SqFilt_CutOff) ) );
%      Fout_SF(i)= Fin(i)/ oGAIN;   
      AtEDFAout_SqFilt_t(i)= AtEDFAout_t_sh(i);
  end
end

%% noisesim filtered
OptFilt=load('OptFilt.dat');
OptFilt_t=fft(OptFilt);
OptFilt_tP= OptFilt_t.* conj(OptFilt_t)/ Carrier.NPtos_Tot;
OptFilt_tP= fftshift(OptFilt_tP);


%% grafica espectro pre/post filtado (cuadrado y noisesim)
AtEDFAout_SqFilt_tP= AtEDFAout_SqFilt_t.* conj(AtEDFAout_SqFilt_t)/ Carrier.NPtos_Tot;

figure('Name','Input/Output noisesim optical Filter in frequency domain');
semilogy(vGHz2, RZPulsesTrain_tP, '.-b', vGHz2, AtEDFAout_tP, '.-g', vGHz2, AtEDFAout_SqFilt_tP, '.-k', vGHz2, OptFilt_tP, '.-r');
legend('Input', 'noisy', 'square', 'noisesim');
xlabel ('v [GHz]');
ylabel ('P [W]');

%% señal pre/post filtado (cuadrado y noisesim)
AtEDFAout_SqFilt_t= fftshift(AtEDFAout_SqFilt_t);
AtEDFAout_SqFilt= ifft(AtEDFAout_SqFilt_t);
figure('Name','Input/Output noisesim optical Filter in time domain');
semilogy(TimeVector, RZPulsesTrain, '.-b', TimeVector, AtEDFAout, '.-g', TimeVector, AtEDFAout_SqFilt, '.-k', TimeVector, OptFilt, '.-r');
legend('Input', 'noisy', 'square', 'noisesim');
xlabel ('t [s]');
ylabel ('A [\sqrt{W}]');


%%  antitransformada square
% Fout_SF_a=ifft(fftshift(Fout_SF));
% figure
% plot((1:siz2)* Carrier.dt, u0,'r.-',(1:siz2)* Carrier.dt,Fout_SF_a,'b.-')
