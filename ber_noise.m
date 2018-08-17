function ber_noise
clear all
close all

CLIENTS= 1;

FilesPath= '~/Documentos/PONs/Reporte/Graphs/';
% cd /home/victor/Documentos/PONs/Reporte/Graphs/

% INPUTFILE='/home/victor/Documentos/PONs/Reporte/Graphs/AT_1_30.dat';
% INPUTFILE='/home/victor/Documentos/PONs/Reporte/Graphs/AT_1_25.dat';
% INPUTFILE='/home/victor/Documentos/PONs/Reporte/Graphs/AT_1_20.dat';
% INPUTFILE='/home/victor/Documentos/PONs/Reporte/Graphs/AT_1_19.dat';
% INPUTFILE='/home/victor/Documentos/PONs/Reporte/Graphs/AT_1_15.dat';
% INPUTFILE='/home/victor/Documentos/PONs/Reporte/Graphs/AT_1_9.dat';
% INPUTFILE='/home/victor/Documentos/PONs/Reporte/Graphs/AT_1_7.dat';

% INPUTFILE='AT_1_30.dat';
INPUTFILE='AT_1_25.dat';      % Pas de memoire!
% INPUTFILE='AT_1_20.dat';
% INPUTFILE='AT_1_19.dat';
% INPUTFILE='AT_1_15.dat';
% INPUTFILE='AT_1_9.dat';
% INPUTFILE='AT_1_7.dat';

OUTPUTFILE=['BERSNR',INPUTFILE];
fidOUTPUTFILE= fopen(OUTPUTFILE,'w');
fprintf(fidOUTPUTFILE,'#OSNR\tBER\n');

INPUTFILE=[FilesPath,INPUTFILE];

% OSNR parameters [dB] [added \simeq K]
OSNRSTART= -20;
OSNRSTEP= 5E-1;   % linear step
OSNRSTOP= 10;

% DSNR parameters [dB]
DSNRdB= 99;


for OSNRdB= OSNRSTART:OSNRSTEP:OSNRSTOP
    fprintf(1,'calculando OSNR=\t%i\n',OSNRdB);

    BitsDisc= noisesim(CLIENTS, DSNRdB, OSNRdB, INPUTFILE);

    % Input file
        InpFile= fopen(INPUTFILE,'r');
        InBitString= fread(InpFile,'char');
        fclose(InpFile);

    % error count 
    count= size(BitsDisc,1);
    errors= 0;
    for i=1:size(BitsDisc,1)
        if (InBitString(i)~=BitsDisc(i) )
            errors= errors+ 1;
        end
    end
    BER= errors/ count;
    fprintf(fidOUTPUTFILE,'%e\t%e\n',OSNRdB,BER);
end
fclose(fidOUTPUTFILE);
