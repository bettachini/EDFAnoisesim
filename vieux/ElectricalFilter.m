function SignalVector=ElectricalFilter(SignalVector, SignalVectorSize)
%   /* Digital filter designed by mkfilter/mkshape/gencode   A.J. Fisher
%   Command line: /www/usr/fisher/helpers/mkfilter -Bu -Lp -o 2 -a 1.5625000000e-02 0.0000000000e+00 -l
% 
%   filtertype    =    Butterworth 
%    passtype    =    Lowpass 
%    order    =    2 
%    samplerate    =    6.4E11 	= 2^6/ bit slot
%   */

  NZEROS= 2;
  NPOLES= 2;
  xve= zeros(NZEROS+ 1);
  yve= zeros(NPOLES+ 1);

  % BW= 10GHz
  % #define eGAIN   4.441320406e+02
  % BW= 5GHz
  % #define eGAIN   1.717988320e+03
  % BW= 6GHz
  eGAIN= 1.201146288e+03;

  for i=1:SignalVectorSize
    xve(1)= xve(2); xve(2)= xve(3); 
    xve(3)= SignalVector(i)/ eGAIN;
    yve(1)= yve(2); yve(2)= yve(3);
    yve(3)= (xve(1)+ xve(3) ) +2* xve(2)+ (-0.9200713754* yve(1) ) + (1.9167412232* yve(2) );	% BW= 6GHz
%      + ( -0.8703674775 * yve[0]) + (  1.8613611468 * yve[1]);	% BW= 10GHz
%      + ( -0.9329347318 * yve[0]) + (  1.9306064272 * yve[1]);	% BW= 5GHz
%      + ( -0.9200713754 * yve(1)) + (  1.9167412232 *yve(2) );	% BW= 6GHz
    SignalVector(i)= yve(3);
  end