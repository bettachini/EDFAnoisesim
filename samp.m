function samp

a=load('Samp0.dat');
b=load('Samp1.dat');
siza=size(a,1);
sizb=size(b,1);
I0p=sum(a(:))/siza
I1p=sum(b(:))/sizb
Sigma0=sqrt(var(a(:)))
Sigma1=sqrt(var(b(:)))
Ith=(Sigma0* I1p+ Sigma1* I0p)/(Sigma0+ Sigma1)
