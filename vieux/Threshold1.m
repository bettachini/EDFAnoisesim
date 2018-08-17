function [Id, DSigmaNoise]= Threshold1(Carrier, RZBit0, RZBit1Gauss, OSigmaNoise, DSNR, Pmean, FAtt)

% DISCRIMINATION BY DISPERSION THRESHOLD [Agrawal 4.5]
    NPulThr=5;			% averaged bits to obtain threshold

% DIAGRAM REQUIRED TO SELECT MIN & MAX
  Min= 40;
  Max= 50;

  One=zeros(Carrier.NPtos_Bit,1);
  Zero= zeros(Carrier.NPtos_Bit,1);
  n= Max- Min+1;
  Id=0;

% OPTICAL NOISE VECTOR FOR THRESHOLD DETERMINATION BITS
  % ONoiseVector= zeros(2*Carrier.NPtos_Bit* NPulThr,1);
  % fprintf(1,'OSigmaNoise=\t%e\n',OSigmaNoise);			% TEST
  % GenRuidoRapido(ONoiseVector, *OSigmaNoise, 2*(*Carrier).NPtos_Bit* NPulThr);		% NoiseVector amplitude
  ONoiseVector= wgn(2* Carrier.NPtos_Bit* NPulThr,1,OSigmaNoise^2,'linear','real');          % MATLAB GAUSSIAN NOISE
  % save -ASCII 'ONoiseVectorMat.dat' ONoiseVector
  
% DETECTOR (THERMAL) NOISE VECTOR FOR THRESHOLD DETERMINATION BITS
  %DNoiseVector2= zeros(2*Carrier.NPtos_Bit* NPulThr,1(;
  DSigmaNoise= Pmean* sqrt(1/ DSNR);            % amplitude of noise (Agrawal 4.4.11) [Santiago I.]
  % printf("DSigmaNoise=\t%e\n",*SigmaNoise);			% TEST
  % GenRuidoRapido(DNoiseVector2, *DSigmaNoise, 2*(*Carrier).NPtos_Bit* NPulThr);		% NoiseVector amplitude
  DNoiseVector2= wgn(2* Carrier.NPtos_Bit* NPulThr,1,DSigmaNoise^2,'linear','real');          % MATLAB GAUSSIAN NOISE
  
  % int reject=0;
  for Pul=1: NPulThr
    sum0= 0; sum_sqr0= 0; sum1= 0; sum_sqr1= 0;

    % DETERMINATION BITS: CREATION & OPTICAL NOISE
    for i=1: Carrier.NPtos_Bit
      One(i)= RZBit1Gauss(i)+ ONoiseVector(i+ Carrier.NPtos_Bit* (Pul- 1) );		% optical noise addition      
      Zero(i)= RZBit0(i)+ ONoiseVector(i+ Carrier.NPtos_Bit* (Pul+ NPulThr -1) );	% optical noise addition
      One(i)= One(i)* FAtt;		% Attenuation for total fibre path
      Zero(i)= Zero(i)* FAtt;
    end
    % Optical filtering
    One= OpticalFilter(One, Carrier.NPtos_Bit);
    Zero= OpticalFilter(Zero, Carrier.NPtos_Bit);

    % -> CURRENT + ELECTRICAL NOISE
    for i=1: Carrier.NPtos_Bit
      One(i)= One(i)* One(i);							% optical amplitude -> optical power= electrical current
      One(i)= One(i)+ DNoiseVector2(i+ Carrier.NPtos_Bit* (Pul- 1)); 		% electrical noise addition
      Zero(i)= Zero(i)* Zero(i);				  		% optical amplitude -> optical power= electrical current
      Zero(i)= Zero(i)+ DNoiseVector2(i+ Carrier .NPtos_Bit* (Pul+ NPulThr- 1) ); 	% electrical noise addition
    end
	% Electrical filtering
    One= ElectricalFilter(One, Carrier.NPtos_Bit);
    Zero= ElectricalFilter(Zero, Carrier.NPtos_Bit);

%     save -ASCII 'ZeroMat.dat' Zero
%     save -ASCII 'OneMat.dat' One
    
    for i=Min:Max
      % fprintf(1,'One[%i]= %e\n',i,One(i) );     % TEST
      sum1= sum1+ One(i);
      One(i)= One(i)* One(i);
      sum_sqr1= sum_sqr1+ One(i);

      sum0= sum0+ Zero(i);
      Zero(i)= Zero(i)* Zero(i);
      sum_sqr0= sum_sqr0+ Zero(i);
    end
        
    I1= sum1/n;		% moyenne1
    I0= sum0/n;		% moyenne0

%     fprintf('n= %f\n',n); % TEST
%     fprintf('sum0= %.3e\tsum1= %.3e\n',sum0, sum1); % TEST
%     fprintf('sum_sqr0= %.3e\tsum_sqr1= %.3e\n',sum_sqr0, sum_sqr1); % TEST

    sigma1= sqrt(( 1/ ( n- 1)) * (sum_sqr1 - ( (sum1* sum1)/ n) ) );
    sigma0= sqrt(( 1/ ( n- 1)) * (sum_sqr0 - ( (sum0* sum0)/ n) ) );

%     /*
%     if (sigma0 != sigma0 && sigma1 != sigma1) reject++;
%     else {
%       if (sigma0 != sigma0) sigma0= 0;	% if sigma0 too small (NaN), sigma0 -> 0
%       if (sigma1 != sigma1) sigma1= 0;	% if sigma1 too small (NaN), sigma1 -> 0
%     */
    %printf("sum0= %e\tsum1= %e\n",sum0,sum1); % TEST
    %printf("Sigma0p= %e\tSigma1p= %e\n",sigma0,sigma1); % TEST
    %printf("I0p= %e\tI1p= %e\n",I0,I1); % TEST
    %}
    Id= Id+ (sigma0* I1+ sigma1* I0)/ (sigma0+ sigma1);
    % fprintf(1,'Id[%i]= %e\n',Pul,Id); % TEST
  end
  % Id*= (1/ (float) (NPulThr- reject) );
  Id= Id/ NPulThr;