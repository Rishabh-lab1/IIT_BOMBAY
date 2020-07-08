 close all
width = 6;     % Width in inches
height = 2;    % Height in inches
      figure
       subplot(121)
      aa=xp(:,1);
      bb=zp(:,1);
     [xc,yc]=meshgrid(unique(aa),unique(bb));
     zT=griddata((aa(:)),bb(:),prho,xc,yc,'natural');
        zT=log10(zT);
       hh= pcolor(unique(aa),unique(bb),(zT));
        caxis([0.5 2.5])
        set(hh, 'EdgeColor', 'none');
        %shading inter
        colormap(jet)
      % colormap(parula(10))
        set(gca,'fontweight','bold','fontsize',12);
%         hc=colorbar('SouthOutside');
%        set(get(hc,'XLabel'),'string','log Resistivity(\Omega m)','fontweight','bold','fontsize',12)
        cmap=colormap;
       cmap1=flipdim(cmap,1);
       colormap(cmap1);
       
      
       camlight; 
       lighting phong 

        %set(gca,'projection','perspective') % allow axes to converge
        xlabel('Distance (m)','fontweight','bold','fontsize',12)
        ylabel('Depth (m)','fontweight','bold','fontsize',12)  
        % Set Tick Marks
 set(gca,'XTick',0:250:750);
 set(gca,'YTick',-100:25:0);

% Here we preserve the size of the image when we save it.
set(gcf,'InvertHardcopy','on');
set(gcf,'PaperUnits', 'inches');
papersize = get(gcf, 'PaperSize');
left = (papersize(1)- width)/2;
bottom = (papersize(2)- height)/2;
myfiguresize = [left, bottom, width, height];
set(gcf,'PaperPosition', myfiguresize);

% Save the file as PNG

        
        
    subplot(122)
    histlog(log10(prho),30);
    set(gca,'fontweight','bold','fontsize',12);
xlim([0.5 2.5]);
xlabel('log Resistivity (\Omega\cdotm)','fontweight','bold','fontsize',12);
ylabel('No. of cells','fontweight','bold','fontsize',12); 

set(gca,'XTick',0.5:0.5:2.5);
%set(gca,'YTick',[1 10 100 1000]);

 set(gcf,'InvertHardcopy','on');
set(gcf,'PaperUnits', 'inches');
papersize = get(gcf, 'PaperSize');
left = (papersize(1)- width)/2;
bottom = (papersize(2)- height)/2;
myfiguresize = [left, bottom, width, height];
set(gcf,'PaperPosition', myfiguresize);


%print('model_test_gfcml2','-dpng','-r300');
print('model_Geophysics_Revision','-dpng','-r300');