function [kde_cen,fuzzy_weight]=cen_value(fi,xi,n_cl)
  %dec_fi = sort(fi,'descend');
  gmfit = gmdistribution.fit(fi',n_cl)
       for i=1:n_cl
           
        [c index] = min(abs(fi-gmfit.mu(i)));
      
        % k = find(fi==gmfit.mu(i));
%          if kden(k)==0
%            wck(i)=1;
%          else
%          wck(i)=nob./(kden(k)); 
%          end
        kde_cen(i)=xi(index);
        fuzzy_weight(i)=gmfit.ComponentProportion (i);
       end
       kde_cen=kde_cen';
       %fuzzy_weight=fuzzy_weight';
       fuzzy_weight=[15;15];