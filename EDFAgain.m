function EDFAgain
% function G_EDFAdB=EDFAgain(Pin)

c= load('EDFADatasheet.csv');    % datasheet AMP-ST-20
f= fittype('a0+ a1*PindBm+ a2*PindBm^2', 'coefficients', {'a0','a1','a2'}, 'independent', 'PindBm');
cfun= fit(c(:,1),c(:,2),f);
% G_EDFAdB= cfun.a0+ cfun.a1*Pin+ cfun.a2*Pin^2;

% %{
%% fit check
in_pow=[-35:3];
gain_pow= cfun.a0+ cfun.a1* in_pow+ cfun.a2* in_pow.^2;
figure(2)
plot(in_pow, gain_pow, '.-r', c(:,1), c(:,2),'-b');

out_pow= in_pow+ gain_pow;
figure(3)
plot(in_pow, out_pow);
xlabel('Input power [dBm]');
ylabel('Output power [dBm]');
