              clear all
             close all
            clc
            tic
            addpath('gradient');
            addpath('GFCM');
            cen=[];
           
             models=[];
             inv_model=[];
             zone_model=[];
%             addpath('C:\Users\Dr.S.P.Sarma\Dropbox\Anand Singh\P.HD\CODES\dc\ELRIS2D\elris_v12\GFCM');
%              addpath('C:\Users\Dr.S.P.Sarma\Dropbox\Anand Singh\P.HD\CODES\dc\ELRIS2D\elris_v12\gradient');
%             addpath('C:\Users\Dr.S.P.Sarma\Dropbox\Anand Singh\P.HD\CODES\dc\ELRIS2D\elris_v12\inversion');
            norm_p=1;
            epsilon=0.00001;
            als=10^-6;
            alx=0.02;
            alz=0.02;
            alxx=0.02;
            mtype=1;
            itmax=5;
            read_data;
            data=ans;
            
            
            alfax=1;
            alfaz=1;
           % data.zmax=100;
            yky=1/data.zmax;%
            %             yky=1/((data.nel-1)*data.ela);
            %             yky=1/data.zmax;
            lambda=std(log(data.roa));
            
            
            switch mtype
            case 0
                xa=1; za=1;
            case 1
                xa=2; za=1; % divides each cell into half
            end
            % Mesh generator
            switch mtype
                case 0 %Fine mode selected
                    [p,t,nlay,tev,par,npar,z,xel,nx,nz]=meshgena(data);
                    
                    parc=1:npar;
                    parc=reshape(parc,nlay,2*(data.nel-1));
                    parc=[parc;zeros(1,size(parc,2))];
                    parc=[zeros(size(parc,1),1),parc,zeros(size(parc,1),1)];
                    C=full(delsq(parc));
                    say=1;
                    for k=1:nx
                        for m=1:nz
                            yx1=(k-1)*xa+1;yx2=(k-1)*xa+xa+1;
                            yy1=(m-1)*za+1;yy2=(m-1)*za+za+1;
                            xp(say,:)=[xel(yx1) xel(yx2) xel(yx2) xel(yx1)];
                            zp(say,:)=[z(yy1) z(yy1) z(yy2) z(yy2)];
                            say=say+1;
                        end
                    end
                case 1 % Normal mode selected
                    [p,t,nlay,tev,par,npar,z]=meshgen(data);
                    
                    parc=1:npar;
                    say=1;
                    for k=1:data.nel-1
                        for m=1:length(z)-1
                            xp(say,:)=[data.xelek(k) data.xelek(k+1) data.xelek(k+1) data.xelek(k)];
                            zp(say,:)=[z(m) z(m) z(m+1) z(m+1)];
                            say=say+1;
                        end
                        
                    end
                    parc=reshape(parc,nlay,data.nel-1);
                    parc=[parc;zeros(1,size(parc,2))];
                    parc=[zeros(size(parc,1),1),parc,zeros(size(parc,1),1)];
                    C=full(delsq(parc));
            end
            [sig,es,ds,akel,V1,k1,prho,so,indx,pma,nu]=initial(t,p,data,yky,npar) ;
            
           
            sd=1./data.roa.^.025;
            Rd=diag(sd);
            if mtype==1;
            [Ws,Wx,Wz] = calcWTW(diff(data.xelek),diff(z));
            else
            [Ws,Wx,Wz] = calcWTW(diff(xel),diff(z));
            end
            prho_h=prho;
            prho_v=3*prho;
            %[C,Gx,Gz] = calcWTW(ones(npar,1),diff(data.xelek),diff(z));
          %  [C,Gx,Gz] = calcWTW(ones(npar,1),diff(xel),diff(z));
          
%           pause;
            for iter=1:itmax
                % Forward operator
                
                [Jh,Jv,ro]=forward(yky,t,es,sig,so,data.nel,akel,1,tev,k1,indx,V1,data,prho,npar,par,p,prho_h,prho_v);
              % [Lambdaa,psinv,C] = ACBAnalysis(J,72,length(z)-1,2,8,2);
           
                dd=log(data.roa(:))-log(ro(:));
                misfit=sqrt((Rd*dd)'*(Rd*dd)/data.nd)*100;
                % Parameter update
                
              %  [misfit,sig,prho,ro]=pupd(data,J,par,yky,t,es,akel,tev,k1,indx,V1,prho',npar,dd,so,p,C,lambda,Rd,iter);
%                 
   %Updating model parameters

%Damping factor
while lambda<0.01
    lambda=0.01; %default 0.01
end
%smoothness constrained least squares
%smoothness constrain is a second order laplacian
%  [gg,kk]=size(J);
%  C=eye(kk);
%b=(J'*Rd'*Rd*dd-lambda*C*(log(1./prho(:))));
%b=(J'*Rd'*Rd*dd);
%if iter==1
J=[Jh Jv];
CC= [C zeros(length(prho));zeros(length(prho)) C]; 
b=(J'*Rd'*Rd*dd-lambda*CC*((1./([prho_h(:);prho_v(:)]))));
A=(J'*Rd'*Rd*J+lambda*CC);
% else
% %  b=(J'*Rd'*Rd*dd-lambda*C*((1./prho(:))));
% %  A=(J'*Rd'*Rd*J+lambda*C);
%  %[RD,RI]=adaptive_lp(Rd,log(data.roa(:)),log(ro(:)),J,1./parg,dp,C,2,10^-2);
% % [Rd,Rs,Rx,Rz]=adaptive_lp(Wd,Ws,Wx,Wz,dobs,d,J,m,dm,p,epsilon)
% [RD,Rs,Rx,Rz,Rxx]=adaptive_lp(Rd,Ws,Wx,Wz,C,log(data.roa(:)),log(ro(:)),J,1./parg,dp,norm_p,epsilon);
% [WTW]=regu_matrix(als,Ws,Rs,alx,Wx,Rx,alz,Wz,Rz,alxx,C,Rxx);
%   b=(J'*Rd'*Rd*dd-lambda*WTW*((1./prho(:))));
%   A=(J'*Rd'*Rd*J+lambda*WTW);  
% %b=(J'*Rd'*RD*Rd*dd-lambda*C*RI*((1./prho(:))));
% % A=(J'*Rd'*RD*Rd*J+lambda*C*RI);  
% end
dp=A\b;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%change
parg_h=1./((1./prho_h(:)).*exp(dp(1:(length(dp)/2))));
parg_v=1./((1./prho_v(:)).*exp(dp((length(dp)/2)+1:end)));
parg = sqrt(parg_h.*parg_v);
prho = parg;
prho_h = parg_h;
prho_v = parg_v;

%  for i=1:length(parg)
%    if parg(i)>2500  
%        parg(i)=2500;
%    elseif parg(i)<100  
%        parg(i)=100;
%    end
%  end
rhoort=exp(sum(log(parg)./length(parg)));
sigtmp(1:es)=1./(rhoort);
for s=1:npar
    sigtmp(par(s).ucg)=1./parg(s);
end
% Test the updated model
%[Jh,Jv,rog]=forward(yky,t,es,sigtmp,so,data.nel,akel,0,tev,k1,indx,V1,data,prho,npar,par,p,prho_h,prho_v);
 [Jh,Jv,rog]=forward(yky,t,es,sigtmp,so,data.nel,akel,0,tev,k1,indx,V1,data,prho,npar,par,p,prho_h,prho_v);
misfitg=sqrt((Rd*dd)'*(Rd*dd)/data.nd)*100;

misfit=misfitg;
ro=rog;
sig=sigtmp;
prho=parg;

%fcmdata=[ log10(prho) m_den m_sus];  
fcmdata=[ log10(prho_h)  log10(prho_v)]; 
%[centers,U,obj_fcn] = gfcm(fcmdata,n_clustter,options,nk,tk);                                                  
%[U,V,F] = GK(Z,U0,2,10^-5,beta,gamma);                                                                         
 options = [2 100 1e-5 0];                                                                                      
   nk=[ 20 20 ;5 5;5  5];                                                                                    
   tk=[ log10(1) log10(4); log10(100) log10(225);1 1];                                                                        
  n_clustter=3;                                                                                                 
 %[centers,U,obj_fcn] = gfcm(fcmdata,n_clustter,options,nk,tk);                                                 
  [centers,U,obj_fcn] = fcm(fcmdata,n_clustter,options);                                                        
%  U_d=U;                                                                                                       
%  U0=rand(3,1992);                                                                                             
%   gamma=[1 1; 0 0];                                                                                           
%   beta=10^3;                                                                                                  
%  [U,centers,F1] = gk_anand(fcmdata,U0',3,10^-5,beta,gamma,200);                                               
%  U=real(U');                                                                                                  
                                                                                 
centers_res_h=real(centers(:,1));                                                                                 
centers_res_v=real(centers(:,2));   

                                                                                                                
for kj=1:length(prho)                                                                                           
         maxU = max(U(1:n_clustter,kj));                                                                        
        kk=find(U(1:n_clustter,kj) == maxU);                                                                    
      % power(1,kj)=centers(kk)*maxU;                                                                           
             powerh=centers_res_h'*U;                                                                              
             cdmh=10.^(powerh);                                                                                   
             prho_h1=real(cdmh');                                                                                   
             
             powerv=centers_res_v'*U;                                                                              
             cdmv=10.^(powerv);                                                                                   
             prho_v1=real(cdmv'); 
             
             
          GU(iter,kj)=kk;                                                                                        
                                                                                                                
end                                                                                                             
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
 %nne=iter/(4*itmax);
 
  pol = polyfit(prho_h,prho_v,3);
   polval = polyval(pol,prho_h);
    %curvemisfit = abs(prho_v - polval);
   prho_v1 = polval;
   prho_h1 = prho_h;
 
 
 nne=0.5;
 prho_h=(1-nne)*prho_h+nne*prho_h1;
 prho_v=(1-nne)*prho_v+nne*prho_v1;
 prho=sqrt(prho_h.*prho_v);
%       for kk=1:length(prho)
%             if prho(kk)<10
%                   prho(kk)=10;
%                else if prho(kk)>1000
%                   prho(kk)=1000;
%                 end
%               end
%       end
%       
     nop = polyfit(prho_h,prho_v,2);
      
      
       mfit(iter)=misfit;
               
                
                
                
                if iter>1
                    farkm=abs(mfit(iter)-mfit(iter-1))./mfit(iter);
                    if farkm<.025
                        break
                    end
                end
                if iter>=2
                    lambda=lambda*.55;
                end
                iter
 
 
 
%  [ff,xxi] = ksdensity(log10(prho),'width',0.01);
% % % %plot(xi,f,'-.k','LineWidth',1.5)
% % figure(500)
%  plot(xxi,ff)
% % hold on
%  if iter > 4
%  [pcc,weight_pcc]=cen_value(ff,xxi,n_clustter)
%  end

 end
       
            
            
            
      
     % pseudo(data.xd,data.psd,data.roa)
      xd=data.xd;
      psd=data.psd;
      [xc,yc]=meshgrid(unique(xd),unique(psd));
        %         F = TriScatteredInterp((xd(:)),psd(:),ro(:));
        
        %         zT = F(xc,yc);
        
        figure
        subplot(211)
        zT=griddata((xd(:)),psd(:),data.roa,xc,yc,'natural');
        zT=log10(zT);
       hh=pcolor(unique(xd),unique(psd),(zT));
       set(hh, 'EdgeColor', 'none');
       colormap jet
       set(gca,'fontweight','bold','fontsize',12);
       hc=colorbar('EastOutside');
       set(get(hc,'XLabel'),'string','log App. Res. (\Omegam)','fontweight','bold','fontsize',12)
      cmap=colormap;
      cmap1=flipdim(cmap,1);
      colormap(cmap1);

       % xlabel('Distance (m)','fontweight','bold','fontsize',12)
        ylabel('Pseudo-Depth (m)','fontweight','bold','fontsize',12)  
        
        subplot(212)
        zT=griddata((xd(:)),psd(:),ro,xc,yc,'natural');
        zT=log10(zT);
       hh=pcolor(unique(xd),unique(psd),(zT));
       set(hh, 'EdgeColor', 'none');
       colormap jet
       set(gca,'fontweight','bold','fontsize',12);
       hc=colorbar('EastOutside');
       set(get(hc,'XLabel'),'string','log App. Res.(\Omega m)','fontweight','bold','fontsize',12)
       cmap=colormap;
      cmap1=flipdim(cmap,1);
      colormap(cmap1);

        xlabel('Distance (m)','fontweight','bold','fontsize',12)
        ylabel('Pseudo-Depth (m)','fontweight','bold','fontsize',12)  
       
        
        
% FIGURE 4 FOR BOTH HORIZONTAL AND VERTICAL 
      figure
      subplot(211);
      aa=xp(:,1);
      bb=zp(:,1);
     [xc,yc]=meshgrid(unique(aa),unique(bb));
     zT=griddata((aa(:)),bb(:),prho_h,xc,yc,'natural');
        zT=log10(zT);
       hh= pcolor(unique(aa),unique(bb),(zT));
%       aa=(xp(:,1)+xp(:,2))/2;
%       bb=(zp(:,2)+zp(:,4))/2;
%      [xc,yc]=meshgrid(unique(aa),unique(bb));
%      zT=griddata((aa(:)),bb(:),prho,xc,yc,'natural');
%         zT=log10(zT);
%       hh= pcolor(unique(aa),unique(bb),(zT));
      % hh=contourf(unique(aa),unique(bb),(zT));
       %caxis([1 2])
       caxis([0 2.5]);
        set(hh, 'EdgeColor', 'none');
        %shading inter
        colormap(jet)
      % colormap(parula(10))
        set(gca,'fontweight','bold','fontsize',12);
        hc=colorbar('EastOutside');
       set(get(hc,'XLabel'),'string','log Resistivity(\Omega m)','fontweight','bold','fontsize',12)
        cmap=colormap;
       cmap1=flipdim(cmap,1);
       colormap(cmap1);
       
      
       camlight; 
       lighting phong 

        %set(gca,'projection','perspective') % allow axes to converge
        xlabel('Distance (m)','fontweight','bold','fontsize',12)
        ylabel('Depth (m)','fontweight','bold','fontsize',12)  
       
        
     figure 
    subplot(212)
      aa=xp(:,1);
      bb=zp(:,1);
     [xc,yc]=meshgrid(unique(aa),unique(bb));
     zT=griddata((aa(:)),bb(:),prho_v,xc,yc,'natural');
        zT=log10(zT);
       hh= pcolor(unique(aa),unique(bb),(zT));
%       aa=(xp(:,1)+xp(:,2))/2;
%       bb=(zp(:,2)+zp(:,4))/2;
%      [xc,yc]=meshgrid(unique(aa),unique(bb));
%      zT=griddata((aa(:)),bb(:),prho,xc,yc,'natural');
%         zT=log10(zT);
%       hh= pcolor(unique(aa),unique(bb),(zT));
      % hh=contourf(unique(aa),unique(bb),(zT));
       %caxis([1 2])
      caxis([0 2.5]);
        set(hh, 'EdgeColor', 'none');
        %shading inter
        colormap(jet)
      % colormap(parula(10))
        set(gca,'fontweight','bold','fontsize',12);
        hc=colorbar('EastOutside');
       set(get(hc,'XLabel'),'string','log Resistivity(\Omega m)','fontweight','bold','fontsize',12)
        cmap=colormap;
       cmap1=flipdim(cmap,1);
       colormap(cmap1);
       
      
       camlight; 
       lighting phong 

        %set(gca,'projection','perspective') % allow axes to converge
        xlabel('Distance (m)','fontweight','bold','fontsize',12)
        ylabel('Depth (m)','fontweight','bold','fontsize',12)
        
        
%       figure
%       aa=xp(:,1);
%       bb=zp(:,1);
%      [xc,yc]=meshgrid(unique(aa),unique(bb));
%      gs=griddata((aa(:)),bb(:),GU(end,:)',xc,yc,'natural');
%        
%        hh= pcolor(unique(aa),unique(bb),gs);
%         set(hh, 'EdgeColor', 'none');
%         set(gca,'fontweight','bold','fontsize',12);
%         hc=colorbar('EastOutside');
%        set(get(hc,'XLabel'),'string','GU','fontweight','bold','fontsize',12)
%          cmap=colormap;
%          cmap1=flipdim(cmap,1);
%          colormap(cmap1);
% 
%         xlabel('Distance (m)','fontweight','bold','fontsize',12)
%         ylabel('Depth (m)','fontweight','bold','fontsize',12)  
%         
%        figure
%         hist(log10(prho),50);
%          set(gca,'fontweight','bold','fontsize',12);
%         xlabel('log Resistivity (\Omega m)','fontweight','bold','fontsize',12);
%       set(gca,'fontweight','bold','fontweight','bold','fontsize',12);
%       xlabel('log Resistivity (\Omega m)','fontweight','bold','fontsize',12);
%       ylabel('No. of cells','fontweight','bold','fontsize',12);
%       
       figure
       plot(mfit,'ok-');
       set(gca,'fontweight','bold','fontsize',12);
       xlabel('Iteration number','fontweight','bold','fontsize',12);
       ylabel('RMSE ','fontweight','bold','fontsize',12);
%       
%    figure
%    plot(cen')

% 
%       figure
%       
%      lam=griddata((aa(:)),bb(:),Lambdaa,xc,yc,'natural');
%         zT=log10(zT);
%        hh= pcolor(unique(aa),unique(bb),lam);
%         set(hh, 'EdgeColor', 'none');
%         %shading interp
%          
%         set(gca,'fontweight','bold','fontsize',12);
%         hc=colorbar('EastOutside');
%        set(get(hc,'XLabel'),'string','lambda','fontweight','bold','fontsize',12)
%        cmap=colormap;
%        cmap1=flipdim(cmap,1);
%        colormap(cmap1);
% 
%         xlabel('Distance (m)','fontweight','bold','fontsize',12)
figure
hist(log10(prho),50);
set(gca,'fontweight','bold','fontsize',12);
%xlim([0.5 3]);
xlabel('log Resistivity (\Omega\cdotm)','fontweight','bold','fontsize',12);
ylabel('No. of cells','fontweight','bold','fontsize',12);

%     figure
%     d2m2=del2(1./prho);
%     zT=griddata((aa(:)),bb(:),d2m1,xc,yc,'natural');
%         
%     hh= pcolor(unique(aa),unique(bb),(zT));
%       % hh=contourf(unique(aa),unique(bb),(zT));
%        %caxis([1 3])
%         set(hh, 'EdgeColor', 'none');
%         %shading inter
%         colormap(jet)
%       % colormap(parula(10))
%         set(gca,'fontweight','bold','fontsize',12);
%         hc=colorbar('EastOutside');
%        %set(get(hc,'XLabel'),'string','log Resistivity(\Omega m)','fontweight','bold','fontsize',12)
% %         cmap=colormap;
% %        cmap1=flipdim(cmap,1);
% %        colormap(cmap1);
% 
%         xlabel('Distance (m)','fontweight','bold','fontsize',12)
%         ylabel('Depth (m)','fontweight','bold','fontsize',12)  
%         
 
figure
loglog(prho_h,prho_v,'b.');
hold on;
loglog([1 10 100],[4 10 225],'r*');

  toc     
  
  
     figure
      aa=xp(:,1);
      bb=zp(:,1);
     [xc,yc]=meshgrid(unique(aa),unique(bb));
     zT=griddata((aa(:)),bb(:),sqrt(prho_v./prho_h),xc,yc,'natural');
       % zT=log10(zT);
       hh= pcolor(unique(aa),unique(bb),(zT));
%       aa=(xp(:,1)+xp(:,2))/2;
%       bb=(zp(:,2)+zp(:,4))/2;
%      [xc,yc]=meshgrid(unique(aa),unique(bb));
%      zT=griddata((aa(:)),bb(:),prho,xc,yc,'natural');
%         zT=log10(zT);
%       hh= pcolor(unique(aa),unique(bb),(zT));
      % hh=contourf(unique(aa),unique(bb),(zT));
       %caxis([1 2])
     %  caxis([0 2.5]);
        set(hh, 'EdgeColor', 'none');
        %shading inter
        colormap(jet)
      % colormap(parula(10))
        set(gca,'fontweight','bold','fontsize',12);
        hc=colorbar('EastOutside');
       set(get(hc,'XLabel'),'string','f','fontweight','bold','fontsize',12)
        cmap=colormap;
       cmap1=flipdim(cmap,1);
       colormap(cmap1);
       
      
       camlight; 
       lighting phong 

        %set(gca,'projection','perspective') % allow axes to converge
        xlabel('Distance (m)','fontweight','bold','fontsize',12)
        ylabel('Depth (m)','fontweight','bold','fontsize',12) 
        
       