function noisesim

clients= 1;

% genera cadena de bits al azar
% % InBitString= zeros(Nbits,1,'single');
% InBitString= rand(Nbits,1);
% InBitString= round(InBitString);

% InBitString=1;            % TEST
InBitString= [1;1;0;1];    % TEST
% InBitString= load('512bits.dat');   % 512 random bits


sizeof= size(InBitString,1);

% SNR parameters [dB]
SNRSTART= -50;
SNRSTEP= 5E-1;	% linear step
SNRSTOP= 15;

% file
file_name='BERvsSNR.dat';
file_id= fopen(file_name, 'w');

for OSNRdB= SNRSTART: SNRSTEP: SNRSTOP
    fprintf(1, 'OSNR= %e\n',OSNRdB);
    BitsDisc= Main(InBitString, OSNRdB, clients);

    i= 1;
    errors= 0;
    while i<sizeof
        if (InBitString(i)>0 && BitsDisc(i)==0)
            errors= errors+ 1;
        end
        i= i+ 1;
    end
    
    y = [OSNRdB, errors/sizeof];
    fprintf(file_id, '%e\t%e\n', y);
end

fclose(file_id);