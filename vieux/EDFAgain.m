function G_EDFAdB=EDFAgain(Pin)

c= load('EDFADatasheet.csv');    % datasheet AMP-ST-20
f= fittype('a0+ a1*PindBm+ a2*PindBm^2','coefficients',{'a0','a1','a2'},'independent','PindBm');
cfun= fit(c(:,1),c(:,2),f);
G_EDFAdB= cfun.a0+ cfun.a1*Pin+ cfun.a2*Pin^2;