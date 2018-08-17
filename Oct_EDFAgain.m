function Oct_EDFAgain
% function G_EDFAdB=EDFAgain(Pin)

%% EDFA AMP-ST-20 datasheet gain vs input power graph
%{
c= load('EDFADatasheet.csv');    % datasheet AMP-ST-20
order=2;
p= polyfit(c(:,1), c(:,2), order);

% Matlab
% f= fittype('a0+ a1*PindBm+ a2*PindBm^2', 'coefficients', {'a0','a1','a2'}, 'independent', 'PindBm');
% cfun= fit(c(:,1),c(:,2),f);
% G_EDFAdB= cfun.a0+ cfun.a1*Pin+ cfun.a2*Pin^2;
%}


%% EDFA AMP-ST-20 datasheet input/output power graph
d= load('EDFA_Datasheet_powers.csv');
order_pow= 3;
poly_powers= polyfit( d(:,1), d(:,2), order_pow);


%% fit check
in_pow=[-35:3];

%{
gain_pow= polyval(p, in_pow);

% gain_pow= cfun.a0+ cfun.a1* in_pow+ cfun.a2* in_pow.^2;	% Matlab
figure(2)
plot(in_pow, gain_pow, '*-r', c(:,1), c(:,2),'-b');
xlabel('Input power [dBm]');
ylabel('Gain [dB]');

out_pow= in_pow+ gain_pow;
figure(3)
plot(in_pow, out_pow);
xlabel('Input power [dBm]');
ylabel('Output power [dBm]');
%}

pow_rel= polyval(poly_powers, in_pow);
figure(4)
plot(in_pow, pow_rel, '*-r', d(:,1), d(:,2),'-b');
xlabel('Input power [dBm]');
ylabel('Output power [dBm]');
poly_powers
