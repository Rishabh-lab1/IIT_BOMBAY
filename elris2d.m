            clear all
            close all
            clc
            tic 
            cen=[];
           
           models=[];
%             addpath('C:\Users\Dr.S.P.Sarma\Dropbox\Anand Singh\P.HD\CODES\dc\ELRIS2D\elris_v12\GFCM');
             addpath('gradient');
%            addpath('inversion');
            mtype=1;
            itmax=20;
            read_data;
            data=ans;
            %data.zmax=100; %defined by user, one can put comment on it
            
            alfax=1;
            alfaz=1;
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
            %
            Rd=diag(sd);
            
            %[C,Gx,Gz] = calcWTW(ones(npar,1),diff(data.xelek),diff(z));
          %  [C,Gx,Gz] = calcWTW(ones(npar,1),diff(xel),diff(z));
            for iter=1:itmax
                % Forward operator
                
                [J,ro]=forward(yky,t,es,sig,so,data.nel,akel,1,tev,k1,indx,V1,data,prho,npar,par,p);
              % [Lambdaa,psinv,C] = ACBAnalysis(J,72,length(z)-1,2,8,2);
           
                dd=log(data.roa(:))-log(ro(:));
                misfit=sqrt((Rd*dd)'*(Rd*dd)/data.nd)*100;
                % Parameter update
                
                [misfit,sig,prho,ro]=pupd(data,J,par,yky,t,es,akel,tev,k1,indx,V1,prho',npar,dd,so,p,C,lambda,Rd);
%                 
               
%                 pdeplot(p,[],t,'xydata',1./sig,'xystyle','flat')
                
%        options = [2.0 100 1e-5 0];
%        n_clustter=3;
%        [centers,U] = gfcm((log10(prho)),n_clustter,options,[10;10;10],[log10(500);log10(100);log10(10)]);
%      % clustrs=sort(centers);
% % %      figure(500)
% % %      plot(i,clustrs(1,1),'r.',i,clustrs(2,1),'b.')
% % %      hold on
%       cen=[cen,centers];
%       models=[models,(log10(prho))];
%       for kj=1:length(prho)
%          maxU = max(U(1:n_clustter,kj));
%         kk=find(U(1:n_clustter,kj) == maxU);
%         %cdm(1,kj)=centers(kk)*maxU;
% %             power=centers'*U;
% %             cdm=10.^(power);
% %             prho=cdm';
%         GU(iter,kj)=kk;
%       end
      
%       for kk=1:length(prho)
%             if prho(kk)<10
%                   prho(kk)=10;
%                else if prho(kk)>1000
%                   prho(kk)=1000;
%                 end
%               end
%       end
      
      
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
       contourf(unique(xd),unique(psd),(zT));
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
       contourf(unique(xd),unique(psd),(zT));
      set(gca,'fontweight','bold','fontsize',12);
       hc=colorbar('EastOutside');
       set(get(hc,'XLabel'),'string','log App. Res.(\Omega m)','fontweight','bold','fontsize',12)
       cmap=colormap;
      cmap1=flipdim(cmap,1);
      colormap(cmap1);

        xlabel('Distance (m)','fontweight','bold','fontsize',12)
        ylabel('Pseudo-Depth (m)','fontweight','bold','fontsize',12)  
       
        
        

      figure
      aa=xp(:,1);
      bb=zp(:,1);
     [xc,yc]=meshgrid(unique(aa),unique(bb));
     zT=griddata((aa(:)),bb(:),prho,xc,yc,'natural');
        zT=log10(zT);
       hh= pcolor(unique(aa),unique(bb),(zT));
        set(hh, 'EdgeColor', 'none');
        %shading interp
         
        set(gca,'fontweight','bold','fontsize',12);
        hc=colorbar('EastOutside');
       set(get(hc,'XLabel'),'string','log Resistivity(\Omega m)','fontweight','bold','fontsize',12)
       cmap=colormap;
      cmap1=flipdim(cmap,1);
      colormap(cmap1);

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
       ylabel('RMSE (%)','fontweight','bold','fontsize',12);
%       
%    figure
%    plot(cen')


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
%         ylabel('Depth (m)','fontweight','bold','fontsize',12)  
     toc  