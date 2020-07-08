function [wck]=fuzzy_weight(data,prho,pcc)
       MIN=min(log10(data.roa))-1;
       MAX=max(log10(data.roa))+1;
       nob=length(prho);
       b=19;
       a=1;
       %nob=50;
       [bandwidth,density,xmesh,cdf]=kde(log10(prho),nob,MIN,MAX);
       %weight_wk = sort(density,'descend');
       xdata=min(pcc):0.1:max(pcc);
       kden=spline(xmesh,density,xdata);
       n_cl=length(pcc);
       for i=1:n_cl
         k = find(xdata==pcc(i));
%          if kden(k)==0
%            wck(i)=1;
%          else
%          wck(i)=nob./(kden(k)); 
%          end
        value(i)=kden(k);
       
       end
       
      
  for i=1:n_cl  
      
    wt(i) = ((b-a)*(value(i)-min(value)))/(max(value)-min(value));
    wck(i)=20-wt(i);
  end  
   wck=wck';