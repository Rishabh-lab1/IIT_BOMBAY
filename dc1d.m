function [rhoa] = dc1d(rho,h,abbytwo)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
s=abbytwo';
%s=[1.5,2,3,4,6,8,10,15,20,25,30,40,50,60,80,100,120,140,160,180,200,250,300,350,400,500,600,800,1000];
res=rho;
ns=length(s);
% res=[100 200 300 1000];
% h=[20 15 30];
Rho=sqrt(prho_h.*prho_v);
N = length(res);
p=xlsread('schlumdata.xlsx');
a=p(1:19,1);
g=p(1:19,2);
f=g.';
T(N,1:29)=res(end);
lemda=[];
T1= [];
fs = [];
for i=1:length(s)
    for j=1:length(a)
        lemda(j)= 10.^(a(j)-log10(s(i)));
    
      for k=N:-1:2
       T(k-1,j)= (T(k,j)+res(k-1)*tanh(lemda(j)*h(k-1)))/(1+((T(k,j)*tanh(lemda(j)*h(k-1)))/res(k-1)));
     end
    T1(j) = T(k-1,j);
fs(j) =f(j)*T1(j);
end
rhoa(i) = sum(fs);
   
    
end
    
%   figure                                                        
% loglog(s,rapp);
% title('apparent resistivity vs electrode separation(AB/2)');
% xlabel('electrode separation');
% ylabel('apparent resistivity');
rhoa=rhoa';
end

