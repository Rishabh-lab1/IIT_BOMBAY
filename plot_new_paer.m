
    close all
      figure
      aa=xp(:,1);
      bb=zp(:,1);
     [xc,yc]=meshgrid(unique(aa),unique(bb));
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
       %caxis([1 2])
        set(hh, 'EdgeColor', 'none');
        %shading inter
        colormap(jet)
      % colormap(parula(10))
        set(gca,'fontweight','bold','fontsize',12);
        hc=colorbar('SouthOutside');
       set(get(hc,'XLabel'),'string','log Resistivity(\Omega m)','fontweight','bold','fontsize',12)
        cmap=colormap;
       cmap1=flipdim(cmap,1);
       colormap(cmap1);
       
      
       camlight; 
       lighting phong 

        %set(gca,'projection','perspective') % allow axes to converge
        xlabel('Distance (m)','fontweight','bold','fontsize',12)
        ylabel('Depth (m)','fontweight','bold','fontsize',12) 
        
        print('a6','-dpng','-r300');