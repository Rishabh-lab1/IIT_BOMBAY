clear all
close all
clc
load 'data_field.dat'

aa(:,1)=data_field(:,2)/2+data_field(:,4)/2;
aa(:,2)=(data_field(:,8)-data_field(:,6))/10;
aa(:,3)=data_field(:,10);
sensvm=aa;
a=sort(sensvm(:,2));
for i=1:length(a)
    index=find(sensvm(:,2)==a(i));
    for kk=1:length(index)
    b(i,1)=sensvm(index(kk),1);
    %b(i,3)=sensvm(index(kk),3);
    end
end
b(:,2)=a;