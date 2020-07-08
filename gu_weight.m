function [wck]=gu_weight(U,prho)
[ix iz]=size(U);
for i=1:ix
    a=U(i,:); %a=[3,8,4,7,1,1]
    b=a>0.5; %b=a>5
    c(i)=sum(b);
end
value=c';
b=5;
a=1;
for i=1:ix  
    wt(i) = ((b-a)*(value(i)-min(value)))/(max(value)-min(value));
    wck(i)=7-wt(i);
end 
  wck=wck';