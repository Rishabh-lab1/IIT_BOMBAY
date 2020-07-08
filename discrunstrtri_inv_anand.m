function [gdd,x1,z1]=discrunstrtri_inv_anand(hlfx,hlfz,frq,rhoh,airz,topx,topy,grat0);
%Plotting the parameterisation scheme 1 consists of rectangles and trapezoids 
% function for discretizing a region and making geometry
%function [gdd,nx,hlf2,x1,z1]=discret(hlfx,hlfz,xblock,frq,rhoh);

%function [gdd,hlf2,x1,z1]=discret(hlfx,hlfz,xblock,zblock,frq,rhoh,airz,indx,cond,topx,topy,grat0);


facz=1.2; a=20;

% hlfx=400; hlfz=500; %half space(to be descritized)
% 
% % and air layer size
% frq=16000; rhoh=1000; xblock=100;
% 
% epol=1;


% frq=[5000];  % frq->frequency in Hz
% 
% rhoh=2000;
% 
% airz=3000;

xblock=50; zblock=20; %rectangular block's length in x- direction, height of air column
%hlfx=1600; hlfz=400;

%topx=-400:50:400;

%topy=0*round(-50*(cos(2*topx)+sin(topx/4)));
%grat0=1;

if min(topy)<0
    topy=topy-min(topy);
end

% %topy=[0,7,27,55,60,106,117,114,99,77,55,40,36,46,68,97,125,146,155,150,134,111,89,74,72];
 

% 
% %  to exclude the topography [
% topy=zeros(size(topx));
% grat0=1; % not to try to make lower interface at 0 level
% %]
% 
% 
% indx=[79 83 111 115];
% 
% cond=[0.01 0.05 0.01 0.05]; % conductivities of cells


% Fuction starts from here
% nx-->no of blocks in x-direction 
nx1=round((hlfx/2-abs(topx(1)))/xblock);
nx2=round((hlfx/2-abs(topx(end)))/xblock);

sx1=(hlfx/2-abs(topx(1)))/nx1;
sx2=(hlfx/2-abs(topx(end)))/nx2;

for i=1:nx1
 topx=[topx(1)-sx1 topx];
 topy=[topy(1) topy];
end

for i=1:nx2
 topx=[topx topx(end)+sx2];
 topy=[topy topy(end)];
end

% % to put extra blocks on the edges of parameterized region
% for i=1:3,
%  if i<=2
%      topx=[topx(1)-sx1 topx topx(end)+sx2];
%      topy=[topy(1) topy topy(end)];
%  else
%      topx=[topx(1)-3*sx1 topx topx(end)+3*sx2];
%      topy=[topy(1) topy topy(end)];
%  end     
% end

maxtopo=max(topy);

%atopy=abs(topy);

hlfz1=hlfz+maxtopo;

% nx-->no of blocks in x-direction 
% nx=round(hlfx/xblock);
% 
% sx=hlfx/nx;


sd=sqrt(2*rhoh/(2*pi*frq*4*pi*1e-07)); %skin depth
%x1=3*sd; z1=4*sd; % half of halfspace in x and z direction
x1=hlfx/2+10*sd; z1=hlfz+10*sd; % half of halfspace in x and z direction

air=[2 4 -x1 x1 x1 -x1 0 0 airz airz 1e-14]; % Air layer
hr=[2 4 -x1 x1 x1 -x1 0 0 -z1 -z1 1/rhoh]; % Halfspace

% nz-->no of blocks in z direction
nz=2;
sz(1)=0;
%sz(2)=sd/10;
sz(2)=zblock;
hlf1=sz(2);
%hlf1(1)=0;
%hlf1(2)=sd/4;

%grat0=0;
while hlf1<hlfz1,
    nz=nz+1;
    sz(nz)=round(facz*sz(nz-1)); 
    hlf1=hlf1+sz(nz);      
    if maxtopo-hlf1<0&grat0==0
        if abs(maxtopo-hlf1)<(facz-1)*sz(nz-1)
            sz(nz)=sz(nz)+maxtopo-hlf1;
            hlf1=hlf1+maxtopo-hlf1;
        else
            sz(nz-1)=sz(nz-1)+maxtopo-hlf1+sz(nz);
            hlf1=hlf1+maxtopo-hlf1;  
            nz=nz-1;
        end
        grat0=grat0+1; % to enter only one time to make lower interface at 0 level
    end
   % hlf1(nz)=hlf1(nz-1)+sz(nz);
   %block�s size in z direction is increased by 2.0
end

%Increasing width of the blocks exponentially in Z-dierction
% fac=0.5; %factor for increasing, 1 for one expontial increment each time 
% while hlf1<hlfz,
%     nz=nz+1;
%     sz(nz)=round(zblock*exp(fac*(nz-2))); 
%     hlf1=hlf1+sz(nz);
%    % hlf1(nz)=hlf1(nz-1)+sz(nz);
%    %block�s size in z direction is increased by 2.0
% end
diff=hlfz1-(hlf1-sz(nz));
sz=sz(1:end-1);
nz=nz-1;

if diff>=sz(nz)
    sz(nz+1)=diff;
    nz=nz+1;
elseif diff>2*sz(nz-1)-sz(nz)
    sz(nz)=(sz(nz)+diff)/2;
    sz(nz+1)=sz(nz);
    nz=nz+1;
else
    sz(nz)=sz(nz)+diff;
end

ii=0;
hlf2(1)=0;
for i=2:nz,
    hlf2(i)=hlf2(i-1)+sz(i);       
end

% filling coordinate information in the GDD matrix

%topy=topy-maxtopo;
%[stopy,inds]=sort(topy);

%topy1=topy-maxtopo;

ii=1; jj=1; jjj=1;
iiii=0;
hnid=[];
body6=[];
for j=1:length(topx)-1,
    iii=1;
    z2=maxtopo; z3=maxtopo;
    x2=topx(j);
    x3=topx(j+1);
    for i=1:nz-1,
        z2=z2-sz(i);
        z3=z3-sz(i+1);
        %body((i-1)*nx+j,:)=[2 4 x2 x3 x3 x2 z2 z2 z3 ...
        %    z3 1/rhoh];
        
        %gdd(:,((i-1)*nx+j)+2)=body((i-1)*nx+j,:)';
        if (z3<topy(j)|z3==topy(j))&(z3<topy(j+1)|z3==topy(j+1))&(z3~=topy(j)|z3~=topy(j+1))
        %if z3<topy(j)&z3<topy(j+1) 
            if iii==1
                if (topy(j)-z3<0.5*sz(i+1)&topy(j)~=z3)|(topy(j+1)-z3<0.5*sz(i+1)&topy(j+1)~=z3)
                %if (topy(j)-z3<0.5*sz(2)&topy(j)~=z3)|(topy(j+1)-z3<0.5*sz(2)&topy(j+1)~=z3)
                %if topy(j)-z3<0.5*sz(i+1)&topy(j+1)-z3<0.5*sz(i+1)
                    
                    body1(ii,:)=[2 4 x2 x3 x3 x2 topy(j) topy(j+1) z3-sz(i+2) ...
                        z3-sz(i+2) 1/rhoh];   
                    %body2(ii,:)=[2 4 x2 x3 x3 x2 topy(j) topy(j+1) z3-sz(i+2) ...
                    %    z3-sz(i+2) 1/rhoh];   
                    iiii=1;
                else
                    body1(ii,:)=[2 4 x2 x3 x3 x2 topy(j) topy(j+1) z3 ...
                        z3 1/rhoh];
                    
                    if topy(j)==z3
                        %body2(ii,:)=[2 3 x2 x3 x3 topy(j) topy(j+1) z3 0 0 ...
                        %    1/rhoh];
                        body6=[body6;[2 3 x2 x3 x3 topy(j) topy(j+1) z3 0 0 ...
                            1/rhoh]];
                        hnid=[hnid,ii];
                    elseif topy(j+1)==z3
                        %body2(ii,:)=[2 3 x2 x2 x3 topy(j) topy(j+1) z3 0 0 ...
                        %    1/rhoh];
                        body6=[body6;[2 3 x2 x2 x3 topy(j) topy(j+1) z3 0 0 ...
                            1/rhoh]];
                        hnid=[hnid,ii];
                    else
                        %body2(ii,:)=[2 4 x2 x3 x3 x2 topy(j) topy(j+1) z3 ...
                        %    z3 1/rhoh];                        
                    end
                end
                ii=ii+1;
                iii=iii+1;
            else
                 body1(ii,:)=[2 4 x2 x3 x3 x2 z2 z2 z3 z3 1/rhoh];                 
                 %body2(ii,:)=[2 4 x2 x3 x3 x2 z2 z2 z3 z3 1/rhoh];               
                 ii=ii+1; 
                 if iiii==1
                     ii=ii-1;
                     iiii=iiii+1;
                end
            end
        elseif (z3>topy(j)&z3<topy(j+1))|(z3<topy(j)&z3>topy(j+1))
            body1(ii,:)=[2 4 x2 x3 x3 x2 topy(j) topy(j+1) z3-sz(i+2) ...
                z3-sz(i+2) 1/rhoh];
            if topy(j)==z3-sz(i+2)
                %body2(ii,:)=[2 3 x2 x3 x3 topy(j) topy(j+1) z3-sz(i+2) 0 0 ...
                %    1/rhoh];
                body6=[body6;[2 3 x2 x3 x3 topy(j) topy(j+1) z3-sz(i+2) 0 0 ...
                    1/rhoh]];
                hnid=[hnid,ii];
            elseif topy(j+1)==z3-sz(i+2)
                %body2(ii,:)=[2 3 x2 x2 x3 topy(j) topy(j+1) z3-sz(i+2) 0 0 ...
                %    1/rhoh];
                body6=[body6;[2 3 x2 x2 x3 topy(j) topy(j+1) z3-sz(i+2) 0 0 ...
                    1/rhoh]];
                hnid=[hnid,ii];        
            else
                %body2(ii,:)=[2 4 x2 x3 x3 x2 topy(j) topy(j+1) z3-sz(i+2) ...
                %    z3-sz(i+2) 1/rhoh];                
            end
            ii=ii+1;
            iii=iii+1;
            iiii=1;
%         else
%              body1(ii,:)=[2 4 x2 x3 x3 x2 z2 z2 z3 z3 1/rhoh];
%              body2(ii,:)=body1(ii,:);   
%              ii=ii+1;
%              iii=iii+1;            
        end
     end
end

if sd>hlfz1
    maxdep=sd;
else
    maxdep=hlfz1;
end

%mindep=500;

ii=1;
iii=1;
body4=[];
for i=2:nz
    if hlf2(i)>maxdep/3&hlf2(i)<2*maxdep/3
        inds=find(body1(:,10)==-hlf2(i)+maxtopo);
        for j=1:round((length(inds)-0.1)/2),
            if (body1(inds(2*j-1),7)==body1(inds(2*j-1),8))&(body1(inds(2*j),7)==body1(inds(2*j),8))
                body3(iii,:)=body1(inds(2*j-1),:);
                body3(iii,4)=body1(inds(2*j),4);
                body3(iii,5)=body1(inds(2*j),5);                  
            else
                hind1=find(hnid==inds(2*j-1));
                if size(hind1,2)~=0
                    body3(iii,:)=body6(hind1,:)
                else
                    body3(iii,:)=body1(inds(2*j-1),:);
                end
                %body3(iii,:)=body1(inds(2*j-1),:);
                hind1=find(hnid==inds(2*j));
                if size(hind1,2)~=0
                    body3(iii+1,:)=body6(hind1,:)
                else
                    body3(iii+1,:)=body1(inds(2*j),:);
                end
                %body3(iii+1,:)=body1(inds(2*j),:);                
                iii=iii+1;
            end
            iii=iii+1;                
        end
        if rem(length(inds)/2,2)~=0
            body3(iii-1,4)=body1(inds(end),4);
            body3(iii-1,5)=body1(inds(end),5);
        end
    elseif hlf2(i)>2*maxdep/3
        inds=find(body1(:,10)==-hlf2(i)+maxtopo);
        nelx=round(length(inds)/3);
        if 3*nelx>length(inds)
            nelx=nelx-1;
        end                
        for j=1:nelx,
            if (body1(inds(3*j-2),7)==body1(inds(3*j-2),8))& ...
                    (body1(inds(3*j-1),7)==body1(inds(3*j-1),8))& ...
                    (body1(inds(3*j),7)==body1(inds(3*j),8))
                body3(iii,:)=body1(inds(3*j-2),:);
                body3(iii,4)=body1(inds(3*j),4);
                body3(iii,5)=body1(inds(3*j),5);  
            elseif (body1(inds(3*j-2),7)==body1(inds(3*j-2),8))& ...
                    (body1(inds(3*j-1),7)==body1(inds(3*j-1),8))
                body3(iii,:)=body1(inds(3*j-2),:);
                body3(iii,4)=body1(inds(3*j-1),4);
                body3(iii,5)=body1(inds(3*j-1),5);  
                
                hind1=find(hnid==inds(3*j));
                if size(hind1,2)~=0
                    body3(iii+1,:)=body6(hind1,:)
                else
                    body3(iii+1,:)=body1(inds(3*j),:);
                end
                %body3(iii+1,:)=body1(inds(3*j),:);
                iii=iii+1;
            elseif (body1(inds(3*j-1),7)==body1(inds(3*j-1),8))& ...
                    (body1(inds(3*j),7)==body1(inds(3*j),8))
                
                hind1=find(hnid==inds(3*j-2));
                if size(hind1,2)~=0
                    body3(iii,:)=body6(hind1,:)
                else
                    body3(iii,:)=body1(inds(3*j-2),:);
                end
                %body3(iii,:)=body1(inds(3*j-2),:);
                body3(iii+1,:)=body1(inds(3*j-1),:);
                body3(iii+1,4)=body1(inds(3*j),4);
                body3(iii+1,5)=body1(inds(3*j),5);                  
                iii=iii+1;                
            else
                hind1=find(hnid==inds(3*j-2));
                if size(hind1,2)~=0
                    body3(iii,:)=body6(hind1,:)
                else
                    body3(iii,:)=body1(inds(3*j-2),:);
                end
                %body3(iii,:)=body1(inds(3*j-2),:);
                hind1=find(hnid==inds(3*j-1));
                if size(hind1,2)~=0
                    body3(iii+1,:)=body6(hind1,:)
                else
                    body3(iii+1,:)=body1(inds(3*j-1),:);
                end
                %body3(iii+1,:)=body1(inds(3*j-1),:);
                hind1=find(hnid==inds(3*j));
                if size(hind1,2)~=0
                    body3(iii+2,:)=body6(hind1,:)
                else
                    body3(iii+2,:)=body1(inds(3*j),:);
                end
                %body3(iii+2,:)=body1(inds(3*j),:);
                iii=iii+2;
            end
            iii=iii+1;                
        end
        if length(inds)-3*nelx==1
            body3(iii-1,4)=body1(inds(end),4);
            body3(iii-1,5)=body1(inds(end),5);
        elseif length(inds)-3*nelx==2
            body3(iii,:)=body1(inds(3*nelx+1),:);
            body3(iii,4)=body1(inds(end),4);
            body3(iii,5)=body1(inds(end),5);
            iii=iii+1;
        end
    else
        inds=find(body1(:,10)==-hlf2(i)+maxtopo);
        for j=1:length(inds)
            hind1=find(hnid==inds(j));
            if size(hind1,2)~=0
                body4=[body4;body6(hind1,:)];
            else
                body4=[body4;body1(inds(j),:)];
            end
        end
        %body4=[body4;body1(find(body1(:,10)==-hlf2(i)+maxtopo),:)];
    end
end

body5=[body4;body3];

if topy(1)>0
    hr=[hr;[2 4 -x1 -hlfx/2 -hlfx/2 -x1 topy(1) topy(1) 0 0 1/rhoh]];
end

if topy(end)>0
    hr=[hr;[2 4 x1 hlfx/2 hlfx/2 x1 topy(end) topy(end) 0 0 1/rhoh]];
end


%gdd=[air' hr' body1'];

%gdd=[air' hr' body2'];
gdd=[air' hr' body1'];

% defining bodies with other conductivities except half space
if nargin==12
    for ii=1:length(indx),
        gdd(end,2+indx(ii))=cond(ii);
    end
end



gd=gdd(1:end-1,5:end);
    
[dl bt]=decsg(gd);

figure
pdegplot(dl)

