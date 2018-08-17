function EDFAfit

c=load('EDFADatasheet.csv');

% f= fittype('a0+ a1*x+ a2*x^2');
f= fittype('a0+ a1*PindBm+ a2*PindBm^2','coefficients',{'a0','a1','a2'},'independent','PindBm');
% f= fittype('a0+ a1*PindBm+ a2*PindBm^2','coefficients',{'a0','a1','a2'},'independent','PindBm');
cfun= fit(c(:,1),c(:,2),f);