            clear all
           % close all
            clc
            cen=[];
           
           models=[];
%             addpath('C:\Users\Dr.S.P.Sarma\Dropbox\Anand Singh\P.HD\CODES\dc\ELRIS2D\elris_v12\GFCM');
%              addpath('gradient');
%             addpath('inversion');
            mtype=1;
            itmax=20;
            read_data;
            data=ans;
            %data.zmax=200; %defined by user, one can put comment on it
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
            % gg=length(sig);
            parg=100*ones(1,npar);
            
%             parg(345:350)=10;
%             parg(345+17:350+17)=10;
%             parg(345+17*2:350+17*2)=10;
%             parg(345+17*3:350+17*3)=10;
%             parg(345+17*4:350+17*4)=10;
%             parg(345+17*5:350+17*5)=10;
%             parg(345+17*6:350+17*6)=10;
            
%              parg(345+17*7:350+17*7)=10;
%              parg(345+17*8:350+17*8)=10;
%             parg(345+17*9:350+17*9)=10;
%              parg(345+17*10:350+17*10)=10;
%              parg(345+17*11:350+17*11)=10;
%             parg(345+17*12:350+17*12)=10;
%             parg(345+17*13:350+17*13)=10;
            
            %sig=(1/1000)*ones(1,gg);
            rhoort=exp(sum(log(parg)./length(parg)));
            sigtmp(1:es)=1./(rhoort);
             for s=1:npar
                sigtmp(par(s).ucg)=1./parg(s);
             end

             prho=parg;
             sig=sigtmp;
             Rd=diag(sd);
            [J,ro]=forward(yky,t,es,sig,so,data.nel,akel,1,tev,k1,indx,V1,data,prho,npar,par,p);
            
        %%% plot data 
        figure
       
       xd=data.xd;
      psd=data.psd;
      [xc,yc]=meshgrid(unique(xd),unique(psd));
     zT=griddata((xd(:)),psd(:),ro,xc,yc,'natural');
     zT=log10(zT);
       pcolor(unique(xd),unique(psd),(zT));
        colormap(jet)
      % colormap(parula(10))
        set(gca,'fontweight','bold','fontsize',12);
        hc=colorbar('EastOutside');
       
      figure
      aa=xp(:,1);
      bb=zp(:,1);
     [xc,yc]=meshgrid(unique(aa),unique(bb));
     
%      load ('noise_prho.dat');
%      prho=noise_prho';
     zT=griddata((aa(:)),bb(:),prho,xc,yc,'natural');
        zT=log10(zT);
       hh= pcolor(unique(aa),unique(bb),(zT));
%       aa=(xp(:,1)+xp(:,2))/2;
%       bb=(zp(:,2)+zp(:,4))/2;
%      [xc,yc]=meshgrid(unique(aa),unique(bb));
%      zT=griddata((aa(:)),bb(:),prho,xc,yc,'natural');
%         zT=log10(zT);
%       hh= pcolor(unique(aa),unique(bb),(zT));
      % hh=contourf(unique(aa),unique(bb),(zT));
       %caxis([0 2])
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
hist(log10(prho),50);
set(gca,'fontweight','bold','fontsize',12);
%xlim([0.5 3]);
xlabel('log Resistivity (\Omega\cdotm)','fontweight','bold','fontsize',12);
ylabel('No. of cells','fontweight','bold','fontsize',12);  
   aa=[data.xd data.nlev ro];  