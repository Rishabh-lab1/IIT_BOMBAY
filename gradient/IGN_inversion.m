% [xc,d,MTX] = InvMainN(MTX,para,x0)

%% Approximate Unconstrained Gauss-Newton with Armijo rule line search 
%
% Input: MTX = Structure of global (see generateMTX)
%        para = parameter structure
%        x0 = initial iterate
%
% Output: xc = solution
%         d = predicted data  
%
% Copyright (c) 2007 by the Society of Exploration Geophysicists.
% For more information, go to http://software.seg.org/2007/0001 .
% You must read and accept usage terms at:
% http://software.seg.org/disclaimer.txt before use.
% 
% Revision history:
% Original SEG version by Eldad Haber and Adam Pidlisecky, 
% Last update August 2006

%%%Screen output during inversion contains the following information:
%%iteration number; current objective function value; data misfit;
%%datanorm; modelnorm; relative gradient norm(current gradient/original gradient). 

%------ Initialize -----------------------------------------

disp('Initializing');

% Extract active cells from the ref model
mref = MTX.mref;



% %  Scale the data
% scl = mean(abs(MTX.dobs));
% fprintf('Data scaling constant = %e\n\n',scl);
% 
% MTX.dobs = MTX.dobs/scl;
% %MTX.RHS = MTX.RHS/scl;
% para.e = para.e/scl;
% % Calculate the data weighting matrix
WdW = data_weight(MTX,para);
MTX.WdW = WdW;

% Extract data 
dobs = MTX.dobs;


if exist('x0'),
    xc = x0(:);   
else,
    disp('Starting model = Ref model');
    xc = mref(:);     
end;

% allocate some numbers
misfit = []; gc = 1; normg0 = 1;

%set up the display 
disp('==================== START OPTIMIZATION ========================');
disp(' ');



itc = 0; 
% Start Gauss-Newton loop
while(norm(gc)/normg0 > para.tol & itc < para.maxit & norm(gc)>1e-20)
   % iteration count
   itc = itc+1;
   
   %%% ---- Function and gradient evaluation -------
   % Update model
  for ii=1:nf,
            frq=freq(ii);    
            % Forward program to compute response
            %fprintf('time taken to calculate forward response\n');
            %tic
            %[rcompf1,rcompf2,rcompf3,rcompf4]=func_forwdata(dl,gdd,frq,xint,epol);
            %[rcompf1,rcompf2,rcompf3,rcompf4,sigma,b,xbs,ybs,yy]=func_forwdata(dl,bt,...
            %    cm1,frq,xint,epol,p2,e2,t2);
            %toc
             [rcompf1,rcompf2,rcompf3,rcompf4,sigma,b,xbs,ybs,yy]=func_forwdata(dl,bt,...
             cm1,frq,xint,epol);
%             rcomp11=[rcomp11;rcompf1/difobs1(ii)];
%             rcomp22=[rcomp22;rcompf2/difobs2(ii)];
            
               rcomp1((ii-1)*nobs+1:ii*nobs)=rcompf1;
               rcomp2((ii-1)*nobs+1:ii*nobs)=rcompf2;
               rcomp3((ii-1)*nobs+1:ii*nobs)=rcompf3;
               rcomp4((ii-1)*nobs+1:ii*nobs)=rcompf4;
            
            % sensitivity matrix calculation
            %fprintf('time taken in sensitivity calculation\n');
            %tic
            %[u,p,e,t,px0i,p0xsort,ix,K,M,Q,G,H,R]=func_forwunadp(dl,gdd,frq,xint,epol);
            [u,p,e,t,px0i,p0xsort,ix,K,B]=func_forwunadp(dl,sigma,b,xbs,...
                ybs,yy,frq,epol,p2,e2,t2);
                      
            [cc,bb]=fsensitiv(u,p,t,frq,xint,cm1,px0i,p0xsort,ix,epol,bt,topy,grat0);
 
            A1=fsens_vlf(epol,vlfem,frq,xint,cm1,cc,bb,u,p,t,K,B,bt,topy,grat0);
            
            %toc
            %if vlfem==1
            %    sensvm=[sensvm;A1];
                %sensvm=[sensvm;complex(real(A1)/difobs1(ii),imag(A1)/difobs2(ii))];
            %elseif vlfem==0
            sensvm((ii-1)*nobs+1:ii*nobs,:)=A1;
                %sensvm=[sensvm;A1];
            %end
            
%             if iswitch==3
%                 %changing e-pol mode to compute another data for joint inversion
%                 vlfem=0;
%                 B1=fsens_vlf(epol,vlfem,frq,xint,gdd,cc,bb,u,p,t,K,B,bt,topy,grat0);
%                 sensvr=[sensvr;B1];
%             end
        end
   % Calculate the (predicted) data from u
   if iswitch==1
    
    d=[log(rcomp3);pi/180*rcomp4];
    %weight=[log(1+noise)*ones(len,1);0.5*noise*ones(len,1)];
    %weight=abs([log(indata1(:,2))-log(indata(:,2));log(indata1(:,3))-log(indata(:,3))]);
    %weight=[wt3;wt4];
    A=[real(sensvm);imag(sensvm)];
elseif iswitch==2
     d=[rcomp1;rcomp2];
     A=[real(sensvm);imag(sensvm)];   
elseif iswitch==3
    d=[rcomp1;rcomp2;rcomp3;rcomp4];
    A=[real(sensvm);imag(sensvm);real(sensvr);imag(sensvr)];
end

   % Calculate the value of the objective function
   %%The data component
   fd = 0.5*(d-dobs)'*(WdW)*(d-dobs);
   %%the model component
    %automatically determine a beta guess
      if itc == 1 &  exist('x0') & isempty(para.BETA);
          
          para.BETA = 0.05*(fd./( (xc-mref)'*MTX.WTW*(xc-mref))); 
      elseif itc == 1  & isempty(para.BETA);
          %%Temporarily assign a value, to be corrected later
          para.BETA = 0;
      end;
   fm = 0.5*para.BETA*( (xc-mref)'*MTX.WTW*(xc-mref));

   %%Add them for the total Objective function
   fc =fd+fm;

   % Evaluate the gradient
   % model objective function gradient
   grad_fm = para.BETA*MTX.WTW*(xc-mref);

   % data objective function gradient (a little more complicated)
   %% use lm to obtain the gradient of the data component
   grad_fd = A'*(d-dobs);

   % Combine the gradients
  
   gc = grad_fd + grad_fm;
   
   %%%% Store some quantities for later use
   misfitold = misfit;
   misfit = sqrt((d-dobs)'*WdW*(d-dobs))/sqrt(dobs'*WdW*dobs);
   if itc == 1, normg0 = norm(gc); f0 = fc; mis0 = misfit; end;

    
   
astr = sprintf('%12s    %8s    %8s    %10s  %10s   %8s',...
               'iter', 'OBJ', 'Misfit', 'DataNorm', 'ModelNorm','RelGrad');

fprintf('%s\n',astr);
   %display parameters
   ostr = sprintf('%12s %12s %12s %12s %12s %12s',...
          [int2str(itc),'/',int2str(para.maxit)],...
          sprintf('%6.2f%c',100*fc/f0,'%'),...
          sprintf('%10.3e',misfit),...
          sprintf('%10.3e',fd),...
          sprintf('%10.3e',fm),...
          sprintf('%10.3e',norm(gc)/normg0));
  
          fprintf('%s\n',ostr);

   
   % mu_LS is mu for the line search

   if misfit < 1e-5
      disp(' misfit below tolerance');   
      return;
   end;

   % Approximate the direction
   % A conjugate gradient solver for
   % (J'*J + para.BETA*WTW) s = -gc
   MTX.mc = xc;
   s = ipcg(A,MTX, para.BETA, -gc, para.intol, para.ininintol, para.init,dobs,d); 
      
   % Test for convergence
   if max(abs(s)) < 1e-3,
      fprintf('    max_s = %e,  norm(g) = %e\n', max(abs(s)), norm(gc));
      fprintf('STEP size too small CONVERGE  ');  return; 
   end;

   % Try the step 
   mu_LS = 1; 
   iarm = 0;     
   % Line search
   while 1,
      xt = xc + mu_LS*s;
      %%%% Evaluate the new objective function
      cm1=[airc,hlfc,xt']; 
      
      for ii=1:nf,
            frq=freq(ii);    
            % Forward program to compute response
            %fprintf('time taken to calculate forward response\n');
            %tic
            %[rcompf1,rcompf2,rcompf3,rcompf4]=func_forwdata(dl,gdd,frq,xint,epol);
            %[rcompf1,rcompf2,rcompf3,rcompf4,sigma,b,xbs,ybs,yy]=func_forwdata(dl,bt,...
            %    cm1,frq,xint,epol,p2,e2,t2);
            %toc
             [rcompf1,rcompf2,rcompf3,rcompf4,sigma,b,xbs,ybs,yy]=func_forwdata(dl,bt,...
             cm1,frq,xint,epol);
%             rcomp11=[rcomp11;rcompf1/difobs1(ii)];
%             rcomp22=[rcomp22;rcompf2/difobs2(ii)];
            
               rcomp1((ii-1)*nobs+1:ii*nobs)=rcompf1;
               rcomp2((ii-1)*nobs+1:ii*nobs)=rcompf2;
               rcomp3((ii-1)*nobs+1:ii*nobs)=rcompf3;
               rcomp4((ii-1)*nobs+1:ii*nobs)=rcompf4;
            
            % sensitivity matrix calculation
            %fprintf('time taken in sensitivity calculation\n');
            %tic
            %[u,p,e,t,px0i,p0xsort,ix,K,M,Q,G,H,R]=func_forwunadp(dl,gdd,frq,xint,epol);
            [u,p,e,t,px0i,p0xsort,ix,K,B]=func_forwunadp(dl,sigma,b,xbs,...
                ybs,yy,frq,epol,p2,e2,t2);
                      
            [cc,bb]=fsensitiv(u,p,t,frq,xint,cm1,px0i,p0xsort,ix,epol,bt,topy,grat0);
 
            A1=fsens_vlf(epol,vlfem,frq,xint,cm1,cc,bb,u,p,t,K,B,bt,topy,grat0);
            
            %toc
            %if vlfem==1
            %    sensvm=[sensvm;A1];
                %sensvm=[sensvm;complex(real(A1)/difobs1(ii),imag(A1)/difobs2(ii))];
            %elseif vlfem==0
            sensvm((ii-1)*nobs+1:ii*nobs,:)=A1;
                %sensvm=[sensvm;A1];
            %end
            
%             if iswitch==3
%                 %changing e-pol mode to compute another data for joint inversion
%                 vlfem=0;
%                 B1=fsens_vlf(epol,vlfem,frq,xint,gdd,cc,bb,u,p,t,K,B,bt,topy,grat0);
%                 sensvr=[sensvr;B1];
%             end
        end
   % Calculate the (predicted) data from u
   if iswitch==1
    
    d=[log(rcomp3);pi/180*rcomp4];
    
    A=[real(sensvm);imag(sensvm)];
elseif iswitch==2
     d=[rcomp1;rcomp2];
     A=[real(sensvm);imag(sensvm)];   
elseif iswitch==3
    d=[rcomp1;rcomp2;rcomp3;rcomp4];
    A=[real(sensvm);imag(sensvm);real(sensvr);imag(sensvr)];
end

     
   
      fd = 0.5*(d-dobs)'*WdW*(d-dobs);
      
      %automatically determine a beta guess
      if itc == 1 & para.BETA ==0;
          para.BETA = 0.5*(fd./( (xt-mref)'*MTX.WTW*(xt-mref))) 
      end;
      fm = 0.5*para.BETA*( (xt-mref)'*MTX.WTW*(xt-mref));       
      ft = fd+fm;
  
      fgoal = fc - para.alp*mu_LS*(s'*gc);

      ostr = sprintf(' %12s %12s %12s %12s %12s %12s',...
      [int2str(itc),'.',int2str(iarm+1)],...
      sprintf('%6.2f%c',100*ft/f0,'%'),...
      sprintf('%10.3e',misfit),...
      sprintf('%10.3e',fd),...
      sprintf('%10.3e',fm),...
      sprintf('%10.3e',[]));
    
      fprintf('%s\n',ostr);
 
      if ft < fgoal, 
        break,
      else
   	    iarm = iarm+1;
        mu_LS = mu_LS/2;    
      end;  
      
      if(iarm > 5)
           disp(' Line search FAIL EXIT(0)');     
           return;             
		  end
      fgoal = fc - para.alp*mu_LS*(s'*gc);
   end  % end line search
   
   % Update model
  % xc = xt; 

   ss = ['iter.',int2str(itc),'.mat'];
   save(ss,'xc');
   
   misfitnew = misfit;
   misfitold = misfitnew;
   xc = xt;
end
%%Create the final model (insert the active cells into the right place)
%xtemp = MTX.mref;
xtemp = xc;
xc = xtemp;