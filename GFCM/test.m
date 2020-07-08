close all
clear all 
clc

data = rand(100,1);
n_clustter=2;
options = [2;	% exponent for the partition matrix U
		100;	% max. number of iteration
		1e-5;	% min. amount of improvement
		0];	% info display during iteration 
      [centers,U,obj_fcn] = gfcm(data,n_clustter,options,[1;1],[0.3;0.7]);
      
    %  for kj=1:length(data)
     % maxU = max(U(1:n_clustter,kj));
     %kk=find(U(1:n_clustter,kj) == maxU);
     rdata=centers'*U;
    %  end
  a=[data,rdata'] ;
    
%       plot(data(:,1), data(:,2),'o');
%       hold on;
%       maxU = max(U);
%       % Find the data points with highest grade of membership in cluster 1
%       index1 = find(U(1,:) == maxU);
%       % Find the data points with highest grade of membership in cluster 2
%       index2 = find(U(2,:) == maxU);
%       line(data(index1,1),data(index1,2),'marker','*','color','g');
%       line(data(index2,1),data(index2,2),'marker','*','color','r');
%       % Plot the cluster centers
%       plot([center([1 2],1)],[center([1 2],2)],'*','color','k')
%       hold off;
