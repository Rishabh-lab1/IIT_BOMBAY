clear all
close all
clc
load 'syntheticVLFR_data.dat'
data=syntheticVLFR_data(:,2);
wdt=ones(50,1);
X=-50:10:50;
Z=[0 5 10  20 40 70 100];
dx=diff(X);
dz=diff(Z);
[G,Gx,Gz] = grad2d(dx,dz);
figure
spy(Gx);
figure
spy(Gz);
wt=ones(51,7);
[WTW,Gx,Gz] = calcWTW(wt,dx,dz);
[WdW,dtw] = data_weight(data,wdt);




















