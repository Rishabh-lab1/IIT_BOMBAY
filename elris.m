function elris
%ELRIS2D Electrical Resistivity/IP Inversion Software 2D. Version 1.0
%
%       ELRIS starts the gui. By default, the directory where the program is
%       called is scanned for data files.

%       The user interface includes components and properties from the
%       IMAGEVIEWER Program by Jiro Doke found at Matlab File Exchange.
%       Copyright 2006-2012 The MathWorks, Inc.
%       Jiro Doke
%       April 2006
%
%       Program was developed and tested on a 64 Bit PC with Windows
%       operating system.
%
%       For further details and help please refer to the README.pdf file
%       located in the root directory of ELRIS distribution.

%       Dr. Ýrfan Akca.
%       iakca@eng.ankara.edu.tr
%       Ankara University, Geophysical Engineering Dept.
%       06100 Ankara, Turkey
%       Revision: 1.1   Date: 2015/05/22
verNumber = '      1.2';
warning off
if nargin == 0
    dirname = [];
else
    if ~ischar(dirname) || ~isdir(dirname)
        error('Invalid input argument.\n  Syntax: %s(DIRNAME)', upper(mfilename));
    end
end
delete(findall(0, 'type', 'figure', 'tag', 'ELRIS'));

bgcolor1 = [.95 .95 .9];
bgcolor2 = [.7 .7 .7];
bgcolor3 = [.4471 .8078 .9373 ];
txtcolor = [.1 .1 .1];
deffont='Helvetica';
%% Create figure
figH = figure(...
    'units'                         , 'normalized', ...
    'busyaction'                    , 'queue', ...
    'color'                         , bgcolor1, ...
    'deletefcn'                     , @stopTimerFcn, ...
    'doublebuffer'                  , 'on', ...
    'handlevisibility'              , 'callback', ...
    'interruptible'                 , 'off', ...
    'menubar'                       , 'none', ...
    'name'                          , 'ELRIS2D : ELectric Resistivity and IP Data Inversion Software (2D)', ...
    'numbertitle'                   , 'off', ...
    'outerposition'                 , [.01 .01 .99 .99], ...
    'resize'                        , 'on', ...
    'resizefcn'                     , @resizeFcn, ...
    'tag'                           , 'ELRIS', ...
    'toolbar'                       , 'none', ...
    'visible'                       , 'off', ...
    'defaultaxesunits'              , 'pixels', ...
    'defaulttextfontunits'          , 'pixels', ...
    'defaulttextfontname'           , 'Consolas', ...
    'defaulttextfontsize'           , 11, ...
    'defaultuicontrolunits'         , 'pixels', ...
    'defaultuicontrolfontunits'     , 'pixels', ...
    'defaultuicontrolfontsize'      , 12, ...
    'defaultuicontrolForegroundColor'     , 'k', ...
    'defaultuicontrolfontname'      , 'Helvetica', ...
    'defaultuicontrolinterruptible' , 'off',...
    'CloseRequestFcn'               , @closefcn);%, ...

%% User interface components

uph(1) = uipanel(...
    'units'                     , 'pixels', ...
    'backgroundcolor'           , bgcolor1, ...
    'parent'                    , figH, ...
    'bordertype'                , 'beveledin', ...
    'tag'                       , 'versionPanel');
uicontrol(...
    'units'                     , 'normalized',...
    'style'                     , 'text', ...
    'foregroundcolor'           , txtcolor, ...
    'backgroundcolor'           , bgcolor1, ...
    'horizontalalignment'       , 'center', ...
    'fontweight'                , 'bold', ...
    'string'                    , sprintf('Version %s', verNumber), ...
    'parent'                    , uph(1), ...
    'tag'                       , 'versionText');
uph(2) = uipanel(...
    'units'                     , 'pixels', ...
    'backgroundcolor'           , bgcolor1, ...
    'parent'                    , figH, ...
    'bordertype'                , 'beveledin', ...
    'tag'                       , 'statusPanel');
uicontrol(...
    'units'                     ,'normalized',...
    'style'                     , 'text', ...
    'foregroundcolor'           , txtcolor, ...
    'backgroundcolor'           , bgcolor1, ...
    'horizontalalignment'       , 'right', ...
    'fontweight'                , 'bold', ...
    'string'                    , '', ...
    'parent'                    , uph(2), ...
    'tag'                       , 'statusText');
uicontrol(...
    'units'                     ,'normalized',...
    'style'                     , 'text', ...
    'foregroundcolor'           , 'b', ...
    'backgroundcolor'           , bgcolor1, ...
    'horizontalalignment'       , 'left', ...
    'fontname'                  , deffont,...
    'string'                    , 'The folder does not contain supported data files.', ...
    'parent'                    , uph(2), ...
    'tag'                       , 'MessageText');


uipanel('units','normalized',...
    'BackGroundColor',[.1 1 .1],...
    'parent',uph(2),...
    'BorderType','etchedin',...
    'Tag','progressbar');




uph(4) = uipanel(...
    'units'                     , 'pixels', ...
    'backgroundcolor'           , bgcolor1, ...
    'parent'                    , figH, ...
    'bordertype'                , 'etchedin', ...
    'tag'                       , 'CurrentDirectoryPanel');%

uicontrol(...
    'style'                     , 'text', ...
    'backgroundcolor'           , [1 1 1], ...
    'horizontalalignment'       , 'left', ...
    'parent'                    , uph(4), ...
    'tag'                       , 'CurrentDirectoryEdit');


uicontrol(...
    'style'                     , 'pushbutton', ...
    'string'                    , '...', ...
    'backgroundcolor'           , bgcolor1, ...
    'callback'                  , @chooseDirectoryCallback, ...
    'TooltipString'             ,'Browse for folder',...
    'parent'                    , figH, ...
    'tag'                       , 'ChooseDirectoryBtn');

irefr=imread([pwd,'\img\refresh2.png']);
uicontrol(...
    'style'                     , 'pushbutton', ...
    'backgroundcolor'           , bgcolor1, ...
    'CData'                     , irefr,...
    'callback'                  , @RefreshDirectoryCallback, ...
    'TooltipString'             ,'Refresh the file list',...
    'parent'                    , figH, ...
    'tag'                       , 'RefreshDirectoryBtn');

% Up Directory Icon
map = [0 0 0;bgcolor1;1 1 0;1 1 1];
upDirIcon = uint8([
    1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
    1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
    1 1 1 0 0 0 0 0 1 1 1 1 1 1 1 1
    1 1 0 3 2 3 2 3 0 1 1 1 1 1 1 1
    1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1
    1 0 2 3 2 3 2 3 2 3 2 3 2 3 2 0
    1 0 3 2 3 2 0 2 3 2 3 2 3 2 3 0
    1 0 2 3 2 0 0 0 2 3 2 3 2 3 2 0
    1 0 3 2 0 0 0 0 0 2 3 2 3 2 3 0
    1 0 2 3 2 3 0 3 2 3 2 3 2 3 2 0
    1 0 3 2 3 2 0 2 3 2 3 2 3 2 3 0
    1 0 2 3 2 3 0 0 0 0 0 3 2 3 2 0
    1 0 3 2 3 2 3 2 3 2 3 2 3 2 3 0
    1 0 2 3 2 3 2 3 2 3 2 3 2 3 2 0
    1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
    ]);
rgbIcon = ind2rgb(upDirIcon, map);

uicontrol(...
    'style'                     , 'pushbutton', ...
    'cdata'                     , rgbIcon, ...
    'TooltipString'             ,'Up one level',...
    'backgroundcolor'           , bgcolor1, ...
    'callback'                  , @upDirectoryCallback, ...
    'parent'                    , figH, ...
    'tag'                       , 'UpDirectoryBtn');

uicontrol(...
    'style'                     , 'listbox', ...
    'backgroundcolor'           , 'white', ...
    'callback'                  , @fileListBoxCallback, ...
    'fontname'                  , 'FixedWidth', ...
    'parent'                    , figH, ...
    'tag'                       , 'FileListBox');

%% Inversion settings panel

ayarpan=uipanel(...
    'units'                     , 'pixels', ...
    'bordertype'                , 'etchedin', ...
    'backgroundcolor'           , 'w', ...
    'fontname'                  , 'Verdana', ...
    'fontsize'                  , 10, ...
    'fontweight'                , 'light', ...
    'parent'                    , figH, ...
    'tag'                       , 'InvSettings');
uicontrol(...
    'style'                     , 'pushbutton', ...
    'units'                     ,'normalized',...
    'TooltipString'             ,'Invert current data',...
    'String'                    ,'Invert',...
    'backgroundcolor'           , 'b', ...
    'foregroundcolor'           ,'w',...
    'callback'                  , @invert, ...
    'parent'                    , ayarpan, ...
    'tag'                       , 'InvBut');
uicontrol(...
    'Parent',ayarpan,...
    'Units','normalized',...
    'HorizontalAlignment','left',...
    'backgroundcolor'           , 'w', ...
    'Position',[.035 .83 .65 .1],...
    'String','Number of iterations',...
    'Style','text',...
    'FontName','Verdana',...
    'FontSize',11,...
    'FontWeight','bold');

uicontrol(...
    'Parent',ayarpan,...
    'Units','normalized',...
    'backgroundcolor'           , 'w', ...
    'position',[.7 .85 .25 .1],...
    'FontSize',11,...
    'String',{' 1',' 2',' 3',' 4',' 5',' 6',' 7',' 8',' 9','10','15' },...
    'TooltipString','Number of iterations',...
    'Style','popupmenu',...
    'Value',5,...
    'Tag','numiter');

uicontrol(...
    'Parent',ayarpan,...
    'Units','normalized',...
    'HorizontalAlignment','left',...
    'backgroundcolor'           , 'w', ...
    'Position',[.035 .42 .45 .2],...
    'String','Mesh type',...
    'Style','text',...
    'FontName','Verdana',...
    'FontSize',11,...
    'FontWeight','bold');


logo=uipanel(...
    'units'                     , 'pixels', ...
    'bordertype'                , 'etchedin', ...
    'backgroundcolor'           , 'w', ...
    'fontname'                  , 'Verdana', ...
    'fontsize'                  , 10, ...
    'fontweight'                , 'light', ...
    'parent'                    , figH, ...
    'tag'                       , 'logo');



uicontrol(   'Parent',logo,...
    'Units','normalized',...
    'HorizontalAlignment','left',...
    'backgroundcolor'           , 'w', ...
    'Position',[.035 .75 .95 .2],...
    'String','Electrical Resistivity Inversion Software - 2D ',...
    'Style','text',...
    'FontName',deffont,...
    'FontSize',12,...
    'foregroundcolor','k',...
    'FontWeight','demi');
uicontrol(   'Parent',logo,...
    'Units','normalized',...
    'HorizontalAlignment','left',...
    'backgroundcolor'           , 'w', ...
    'Position',[.035 .5 .95 .2],...
    'String','Dr. Irfan Akca, 2014',...
    'Style','text',...
    'FontName',deffont,...
    'FontSize',12,...
    'foregroundcolor','k',...
    'FontWeight','demi');
uicontrol(   'Parent',logo,...
    'Units','normalized',...
    'HorizontalAlignment','left',...
    'backgroundcolor'           , 'w', ...
    'Position',[.035 .225 .58 .25],...
    'String','iakca@eng.ankara.edu.tr',...
    'Style','pushbutton',...
    'FontName',deffont,...
    'FontSize',12,...
    'foregroundcolor','b',...
    'FontWeight','demi',...
    'Callback','web mailto:iakca@eng.ankara.edu.tr');


renk3=[95 150 225]/255;
renk4=[179 250 170]/255;

uicontrol(...
    'Parent',ayarpan,...
    'Units','normalized',...
    'backgroundcolor'           , bgcolor1, ...
    'position',[.7 .43 .25 .22],...
    'String',{'Normal' },...
    'FontName','Verdana',...
    'fontweight'                , 'light', ...
    'fontsize'                  , 9, ...
    'ForegroundColor','k',...
    'Style','togglebutton',...
    'TooltipString','Mesh density',...
    'Value',1,...
    'tag','mesh',...
    'Callback',@callbackmesh);

tp1=uipanel(...
    'units'                     , 'pixels', ...
    'bordertype'                , 'etchedin', ...
    'backgroundcolor'           ,  bgcolor3,...
    'fontname'                  , 'Verdana', ...
    'fontsize'                  , 10, ...
    'fontweight'                , 'demi', ...
    'parent'                    , figH, ...
    'tag'                       , 'titlepanel1');
uicontrol(...
    'style'                     , 'text', ...
    'foregroundcolor'           , 'w', ...
    'fontweight'                , 'bold',...
    'backgroundcolor'           , bgcolor3,...
    'horizontalalignment'       , 'left', ...
    'string'                    , 'File Explorer', ...
    'parent'                    , tp1, ...
    'tag'                       , 'baslik1',...
    'units'                     , 'normalized',...
    'FontName'                  ,'Verdana',...
    'position'                  , [.01 .125 .4 .75]  );
tp2=uipanel(...
    'units'                     , 'pixels', ...
    'bordertype'                , 'etchedin', ...
    'backgroundcolor'           ,  bgcolor3,...
    'fontname'                  , 'Verdana', ...
    'fontsize'                  , 10, ...
    'fontweight'                , 'demi', ...
    'parent'                    , figH, ...
    'tag'                       , 'titlepanel2');
uicontrol(...
    'style'                     , 'text', ...
    'foregroundcolor'           , 'w', ...
    'fontweight'                , 'bold',...
    'backgroundcolor'           , bgcolor3,...
    'horizontalalignment'       , 'left', ...
    'string'                    , 'Data Info', ...
    'parent'                    , tp2, ...
    'tag'                       , 'baslik2',...
    'units'                     , 'normalized',...
    'FontName'                  ,'Verdana',...
    'position'                  , [.01 .125 .4 .75]  );
tp3=uipanel(...
    'units'                     , 'pixels', ...
    'bordertype'                , 'etchedin', ...
    'backgroundcolor'           ,  bgcolor3,...
    'fontname'                  , 'Verdana', ...
    'fontsize'                  , 10, ...
    'fontweight'                , 'demi', ...
    'parent'                    , figH, ...
    'tag'                       , 'titlepanel3');
uicontrol(...
    'style'                     , 'text', ...
    'foregroundcolor'           , 'w', ...
    'fontweight'                , 'bold',...
    'backgroundcolor'           , bgcolor3,...
    'horizontalalignment'       , 'left', ...
    'string'                    , 'Inversion Settings', ...
    'parent'                    , tp3, ...
    'tag'                       , 'baslik3',...
    'units'                     , 'normalized',...
    'FontName'                  ,'Verdana',...
    'position'                  , [.01 .125 .74 .75]  );
tp4=uipanel(...
    'units'                     , 'pixels', ...
    'bordertype'                , 'etchedin', ...
    'backgroundcolor'           ,  bgcolor3,...
    'fontname'                  , 'Verdana', ...
    'fontsize'                  , 10, ...
    'fontweight'                , 'demi', ...
    'parent'                    , figH, ...
    'tag'                       , 'titlepanel4');
uicontrol(...
    'style'                     , 'text', ...
    'foregroundcolor'           , 'w', ...
    'fontweight'                , 'bold',...
    'backgroundcolor'           , bgcolor3,...
    'horizontalalignment'       , 'left', ...
    'string'                    , 'Visuals', ...
    'parent'                    , tp4, ...
    'tag'                       , 'baslik4',...
    'units'                     , 'normalized',...
    'FontName'                  ,'Verdana',...
    'position'                  , [.01 .125 .94 .75]  );
tp5=uipanel(...
    'units'                     , 'pixels', ...
    'bordertype'                , 'etchedin', ...
    'backgroundcolor'           ,  bgcolor3,...
    'fontname'                  , 'Verdana', ...
    'fontsize'                  , 10, ...
    'fontweight'                , 'demi', ...
    'parent'                    , figH, ...
    'tag'                       , 'titlepanel5');
tp6=uipanel(...
    'units'                     , 'pixels', ...
    'bordertype'                , 'etchedin', ...
    'backgroundcolor'           ,  bgcolor3,...
    'fontname'                  , 'Verdana', ...
    'fontsize'                  , 10, ...
    'fontweight'                , 'demi', ...
    'parent'                    , figH, ...
    'tag'                       , 'titlepanel6');

uicontrol(...
    'style'                     , 'text', ...
    'foregroundcolor'           , 'w', ...
    'fontweight'                , 'bold',...
    'backgroundcolor'           , bgcolor3,...
    'horizontalalignment'       , 'left', ...
    'string'                    , 'Palette', ...
    'parent'                    , tp5, ...
    'tag'                       , 'baslik5',...
    'units'                     , 'normalized',...
    'FontName'                  ,'Verdana',...
    'position'                  , [.01 .125 .94 .75]  );
uicontrol(...
    'style'                     , 'text', ...
    'foregroundcolor'           , 'w', ...
    'fontweight'                , 'bold',...
    'backgroundcolor'           , bgcolor3,...
    'horizontalalignment'       , 'left', ...
    'string'                    , 'Output', ...
    'parent'                    , tp6, ...
    'tag'                       , 'baslik5',...
    'units'                     , 'normalized',...
    'FontName'                  ,'Verdana',...
    'position'                  , [.01 .125 .94 .75]  );


imp=imread([pwd,'\img\capture3.png']);
impdf=imread([pwd,'\img\','pdf.png']);
imtxt=imread([pwd,'\img\','txt.png']);

tpan=uipanel(...
    'units'                     , 'pixels', ...
    'bordertype'                , 'etchedin', ...
    'backgroundcolor'           ,  'w',...
    'fontname'                  , 'Verdana', ...
    'fontsize'                  , 10, ...
    'fontweight'                , 'demi', ...
    'parent'                    , figH, ...
    'tag'                       , 'toolspan');
uicontrol(...
    'style'                     , 'pushbutton', ...
    'parent'                    , tpan, ...
    'CData'                     ,impdf,...
    'tag'                       , 'capture',...
    'units'                     , 'normalized',...
    'Callback'                  ,  @captbutton,...
    'tooltipstring'             ,'Save to pdf',...
    'FontName'                  ,'Verdana',...
    'position'                  , [.33 .35 .32 .25]);
uicontrol(...
    'style'                     , 'pushbutton', ...
    'parent'                    , tpan, ...
    'CData'                     ,imp,...
    'tag'                       , 'capture',...
    'units'                     , 'normalized',...
    'Callback'                  ,  @snipping,...
    'FontName'                  ,'Verdana',...
    'tooltipstring'             ,'Capture screen',...
    'position'                  , [.3 .7 .4 .2]  );

uicontrol(...
    'style'                     , 'pushbutton', ...
    'parent'                    , tpan, ...
    'CData'                     ,imtxt,...
    'tag'                       , 'capture',...
    'units'                     , 'normalized',...
    'Callback'                  ,  @savetotext,...
    'tooltipstring'             ,'Save to txt',...
    'FontName'                  ,'Verdana',...
    'position'                  , [.33 .05 .35 .25]);

uph(5) = uipanel(...
    'units'                     , 'pixels', ...
    'bordertype'                , 'etchedin', ...
    'backgroundcolor'           , bgcolor1, ...
    'fontname'                  , 'Verdana', ...
    'fontsize'                  , 10, ...
    'fontweight'                , 'demi', ...
    'titleposition'             , 'centertop', ...
    'parent'                    , figH, ...
    'tag'                       , 'DataInfoPanel');


uph(6) = uipanel(...
    'units'                     , 'pixels', ...
    'bordertype'                , 'etchedout', ...
    'fontname'                  , 'Verdana', ...
    'fontweight'                , 'bold', ...
    'titleposition'             , 'centertop', ...
    'backgroundcolor'           , [1 1 1], ...
    'parent'                    , figH, ...
    'tag'                       , 'MainPanel');

%--------------------------------------------------
bg = uibuttongroup('units','normalized',...
    'parent',uph(6),...
    'pos',[.42 .0021 .12 .025],'Visible','on','tag','resip','SelectionChangeFcn',@res_ip_switch);
rd(1) = uicontrol(bg,...
    'style','rad',...
    'unit','normalized',...
    'position',[.001 .001 .5 .9],...
    'string','Res.');
rd(2) = uicontrol(bg,...
    'style','rad',...
    'unit','normalized',...
    'position',[.51 .001 .4 .9],...
    'string','IP');
%--------------------------------------------------


uicontrol(...
    'style'                     ,'togglebutton', ...
    'units'                     ,'normalized',...
    'TooltipString'             ,'Enlarge panel',...
    'String'                    ,'>',...
    'Callback'                  ,  @enlarge,...
    'backgroundcolor'           , bgcolor1, ...
    'foregroundcolor'           ,'k',...
    'parent'                    , uph(6), ...
    'position'                  , [.985 .49 .015 .035],...
    'tag'                       , 'hidebut');

uph(7) = uipanel(...
    'units'                     , 'pixels', ...
    'bordertype'                , 'etchedin', ...
    'backgroundcolor'           , 'w', ...
    'fontname'                  , 'Verdana', ...
    'fontsize'                  , 10, ...
    'fontweight'                , 'demi', ...
    'titleposition'             , 'centertop', ...
    'parent'                    , figH, ...
    'tag'                       , 'VisSetPanel');
uph(8) = uipanel(...
    'units'                     , 'pixels', ...
    'bordertype'                , 'etchedin', ...
    'backgroundcolor'           , 'w', ...
    'fontname'                  , 'Verdana', ...
    'fontsize'                  , 10, ...
    'fontweight'                , 'demi', ...
    'titleposition'             , 'centertop', ...
    'parent'                    , figH, ...
    'tag'                       , 'ColSetPanel');


cnames={'wysiwygcont','seis','red2green','rainbow','polar','no_green','hot','haxby','Spectral10','jet','hsv'};
curfold=pwd;
for k=1:length(cnames)
    im2=imread([curfold,'\img\',cnames{k},'.png']);
    uicontrol(...
        'Parent',uph(8),...
        'Units','normalized',...
        'position',[.1 .95-(k-1)*.07 .8 .04],...
        'FontName','Verdana',...
        'fontweight'                , 'light', ...
        'fontsize'                  , 9, ...
        'ForegroundColor','k',...
        'Style','pushbutton',...
        'Callback',@callbackcolor,...
        'tag',cnames{k},...
        'CData',im2,...
        'tooltipstring',cnames{k},...
        'Enable','on');
end

uicontrol(...
    'Parent',uph(8),...
    'Units','normalized',...
    'position',[.1 .075 .8 .04],...
    'FontName','Verdana',...
    'fontweight'                , 'light', ...
    'fontsize'                  , 11, ...
    'String','Brightness',...
    'ForegroundColor','k',...
    'BackgroundColor','w',...
    'Style','text',...
    'Enable','on');
uicontrol(...
    'Parent',uph(8),...
    'Units','normalized',...
    'position',[.11 .0185 .4 .045],...
    'FontName','Verdana',...
    'fontweight'                , 'light', ...
    'fontsize'                  , 9, ...
    'String','<',...
    'ForegroundColor','k',...
    'Style','pushbutton',...
    'Callback',@callbackbright,...
    'tag','upcol',...
    'tooltip','Darken',...
    'Enable','on');
uicontrol(...
    'Parent',uph(8),...
    'Units','normalized',...
    'position',[.53 .0185 .4 .045],...
    'FontName','Verdana',...
    'fontweight'                , 'light', ...
    'fontsize'                  , 9, ...
    'String','>',...
    'ForegroundColor','k',...
    'Style','pushbutton',...
    'Callback',@callbackbright,...
    'tag','dcol',...
    'tooltip','Brighten',...
    'Enable','on');

uicontrol(...
    'Parent',uph(8),...
    'Units','normalized',...
    'position',[.1 .15 .80 .05],...
    'FontName','Verdana',...
    'fontweight'                , 'light', ...
    'fontsize'                  , 9, ...
    'String','Reverse',...
    'ForegroundColor','k',...
    'Style','pushbutton',...
    'Callback','colormap(flipud(colormap))',...
    'tooltip','Reverses the current colormap',...
    'Enable','on');

butlabels={'Datum x','Electrodes','Contours','Log scale'};
for k=1:4
    uicontrol(...
        'Parent',uph(7),...
        'Units','normalized',...
        'HorizontalAlignment','left',...
        'backgroundcolor'           , 'w', ...
        'Position',[.025 .85-(k-1)*.25 .67 .12],...
        'String',butlabels{k},...
        'Style','text',...
        'FontName',deffont,...
        'FontSize',10,...
        'FontWeight','light',...
        'Tag','text17');
end
% Visual settings buttons
but_func={@tbutton,@togglelines,@toggleelektrot,@toggledatax};
but_def_val=[1 0 0 1 ];
for k=1:4
    up = uipanel(...
        'units'                     , 'normalized', ...
        'backgroundcolor'           , [.9 .9 .9], ...
        'fontname'                  , 'Verdana', ...
        'fontsize'                  , 10, ...
        'fontweight'                , 'demi', ...
        'titleposition'             , 'centertop', ...
        'parent'                    , uph(7), ...
        'tag'                       , ['slidep',num2str(k)]);
    
    uicontrol(...
        'Parent',up,...
        'Units','normalized',...
        'backgroundcolor'           , [179 250 170]/255, ...
        'position',[.02 .01 .96 .96],...
        'String',{'I' },...
        'FontName',deffont,...
        'fontweight'                , 'light', ...
        'fontsize'                  , 9, ...
        'Enable'                    ,'on',...
        'ForegroundColor','k',...
        'Style','togglebutton',...
        'Value',but_def_val(k),...
        'Tag',['gosterim',num2str(k)],...
        'Callback',but_func{k},...
        'CreateFcn',@butcreate);
end
% Data and model sections
axes(...
    'box'                       , 'on', ...
    'handlevisibility'          , 'callback', ...
    'parent'                    , uph(6), ...
    'units'                     ,'normalized',...
    'tag'                       , 'MeasResPsd','Visible','off',...
    'FontName'                  , deffont);
axes(...
    'box'                       , 'on', ...
    'parent'                    , uph(6), ...
    'units'                     ,'normalized',...
    'tag'                       , 'CalcResPsd','Visible','off',...
    'FontName'                  , deffont);
axes(...
    'box'                       , 'on', ...
    'parent'                    , uph(6), ...
    'units'                     ,'normalized',...
    'tag'                       , 'ModRes','Visible','off',...
    'FontName'                  , deffont);

dy=.105;
S={'Electrode Array','Unit Spacing','Profile Range','App. Res. Range','# of electrodes','# n levels','# of Datum','IP Present?','Inverted?'};
for k=1:length(S)
    if mod(k,2)==0
        renk=[ 1 1 1];
    else
        renk=bgcolor2+.2;
    end
    uicontrol(...
        'style'                     , 'text', ...
        'foregroundcolor'           , txtcolor, ...
        'backgroundcolor'           , renk, ...
        'horizontalalignment'       , 'left', ...
        'fontweight'                , 'bold', ...
        'string'                    , S(k), ...
        'parent'                    , uph(5), ...
        'tag'                       , 'infol',...
        'units'                     , 'normalized',...
        'FontName'                  ,'Verdana',...
        'position'                  , [.025 .87 .5 dy ]+[0 -dy*(k-1) 0 0]);
    uicontrol(...
        'style'                     , 'text', ...
        'foregroundcolor'           , 'k', ...
        'backgroundcolor'           , renk, ...
        'horizontalalignment'       , 'left', ...
        'fontweight'                , 'bold', ...
        'string'                    , ':', ...
        'parent'                    , uph(5), ...
        'tag'                       , 'infol',...
        'units'                     , 'normalized',...
        'FontName'                  ,'Verdana',...
        'position'                  , [.45 .87 .01 dy ]+[0 -dy*(k-1) 0 0]);
end


handles             = guihandles(figH);
handles.figPos      = [];
handles.axPos       = [];
handles.lastDir     = dirname;
handles.ImX         = [];
handles.tm          = timer(...
    'name'            , 'image preview timer', ...
    'executionmode'   , 'fixedspacing', ...
    'objectvisibility', 'off', ...
    'taskstoexecute'  , inf, ...
    'period'          , 0.001, ...
    'startdelay'      , .001, ...
    'timerfcn'        , @getDataContents);

resizeFcn;

% Show initial directory
showDirectory;
% Initialization is completed set figure window visible and controls on.
set(figH, 'visible', 'on');
maximize(figH)


%--------------------------------------------------------------------------
% resizeFcn
%   This resizes the figure window appropriately
%   Lowest allowed screen size is 1024x768 pixels.
%--------------------------------------------------------------------------
    function resizeFcn(varargin)
        
        set(figH, 'units', 'pixels');
        figPos = get(figH, 'position');
        
        %         figure can't be too small or off the screen
        if figPos(3) < 1024 || figPos(4) < 768
            figPos(3) = max([1024 figPos(3)]);
            figPos(4) = max([768 figPos(4)]);
            screenSize = get(0, 'screensize');
            if figPos(1)+figPos(3) > screenSize(3)
                figPos(1) = screenSize(3) - figPos(3) - 50;
            end
            if figPos(2)+figPos(4) > screenSize(4)
                figPos(2) = screenSize(4) - figPos(4) - 50;
            end
            
            set(figH, 'position', figPos);
            
        end
        
        set(handles.versionPanel         , 'position', [1, 1, 100, 25]);
        set(handles.versionText          , 'position', [.05 0 .9 .8]);
        set(handles.statusPanel          , 'position', [102, 1, figPos(3)-102, 25]);
        set(handles.statusText           , 'position', [.58, .0, .2 .81]);
        set(handles.MessageText          , 'position', [.02 .0 .5 .8]);
        set(handles.progressbar          , 'position', [.8 0 .002 1]);
        set(handles.CurrentDirectoryPanel, 'position', [20, figPos(4)-30, 192, 20]);
        set(handles.CurrentDirectoryEdit , 'position', [1, 1, 188, 16]);
        set(handles.ChooseDirectoryBtn   , 'position', [215, figPos(4)-30, 20, 20]);
        set(handles.RefreshDirectoryBtn  , 'position', [237, figPos(4)-30, 20, 20]);
        set(handles.UpDirectoryBtn       , 'position', [259, figPos(4)-30, 20, 20]);
        set(handles.FileListBox          , 'position', [20, 525, 260, figPos(4)-586]);
        set(handles.DataInfoPanel        , 'position', [20, 283, 260, 207]);
        set(handles.titlepanel1          , 'position', [20, 530+figPos(4)-590 261 25]);
        set(handles.titlepanel2          , 'position', [20, 492, 260, 25]);
        set(handles.titlepanel3          , 'position', [20, 250, 260, 25]);
        set(handles.titlepanel4          , 'position', [figPos(3)-100, figPos(4)-36, 85, 25]);
        set(handles.titlepanel5          , 'position', [figPos(3)-100, figPos(4)-170, 85, 25]);
        set(handles.titlepanel6          , 'position', [figPos(3)-100, figPos(4)-600, 85, 25]);
        %         set(handles.titlepanel7          , 'position', [figPos(3)-100, figPos(4)-750, 85, 25]);
        
        set(handles.toolspan             , 'position', [figPos(3)-100, figPos(4)-722, 85, 120]);
        
        hs=get(handles.hidebut,'Value');
        if hs==0
            set(handles.MainPanel            , 'position', [290, 40, figPos(3)-400, figPos(4)-50]);
        else
            set(handles.MainPanel            , 'position', [290, 40, figPos(3)-305, figPos(4)-50]);
        end
        set(handles.InvSettings          , 'position', [20, 140, 260, 110]);
        set(handles.logo                 , 'position', [20, 40, 260, 91]);
        
        set(handles.InvBut               , 'position', [.69 .12 .25 .22]);
        tpos=[290, 40, figPos(3)-400, figPos(4)-50];
        et=tpos(1)+tpos(3);
        set(handles.VisSetPanel          , 'position', [et+10 tpos(4)-91 85 105]);
        set(handles.ColSetPanel          , 'position', [et+10 tpos(4)-520 85 400]);
        
        for k=1:4
            set(handles.(['slidep',num2str(k)])              , 'position', [.7 .05+(k-1)*.245 .25 .2]);
        end
        
        set(handles.MeasResPsd           , 'position',[.1 .725 .775 .20]);
        set(handles.CalcResPsd           , 'position',[.1 .425 .775 .20]);
        set(handles.ModRes               , 'position',[.1 .1 .775 .20]);
    end

%--------------------------------------------------------------------------
% showDirectory
%   This function shows a list of data files in the directory
%--------------------------------------------------------------------------
    function showDirectory(dirname)
        
        stopTimer;
        
        if nargin == 1
            handles.lastDir = dirname;
        else
            if isempty(handles.lastDir)
                handles.lastDir = pwd;
            end
        end
        
        set(handles.CurrentDirectoryEdit, 'string', ...
            fixLongDirName(handles.lastDir), ...
            'tooltipstring', handles.lastDir);
        % Scanned file extension(s)
        exts = {'dat'};
        d = [];
        for id = 1:length(exts)
            d = [d; dir(fullfile(handles.lastDir, ['*.' exts{id}]))];
        end
        
        n = sort({d.name});% List of data files
        
        
        d2 = dir(handles.lastDir);
        n2 = {d2.name};
        n2 = n2([d2.isdir]);
        ii1 = strmatch('.', n2, 'exact');
        ii2 = strmatch('..', n2, 'exact');
        n2([ii1, ii2]) = '';% List of directories
        
        if isempty(n)
            handles.DataID = [];
            handles.DataNames = {};
            handles.DataContents = {};
            runTimer = false;
            
        else
            
            %       n
            hayir=[];
            for kn=1:length(n)
                try
                    dtmp=read_data([handles.lastDir,'\',n{kn}]);
                    hayir(kn)=0;
                catch
                    hayir(kn)=1;
                end
            end
            
            n(find(hayir))=[];
            handles.DataID = 1:length(n);
            handles.DataNames = n;
            handles.DataContents = cell(1,length(n));
        end
        if ~isempty(n2)
            n2 = strcat(repmat({'['}, 1, length(n2)), n2, repmat({']'}, 1, length(n2)));
            n = {n2{:}, n{:}};
            handles.DataID = handles.DataID + length(n2);
            set(handles.FileListBox, 'Enable','on');
            
        end
        
        set(handles.FileListBox, 'string', n, 'value', 1,'FontName','Helvetica','FontSize',12.0,'FontWeight','light');
        
        if ~isempty(handles.DataID)
            set(handles.ELRIS, 'selectiontype', 'normal');
            set(handles.FileListBox, 'value', handles.DataID(1),'Enable','off');
            fileListBoxCallback(handles.FileListBox);
        end
        
    end

%--------------------------------------------------------------------------
% getDataContents
%--------------------------------------------------------------------------
    function getDataContents(varargin)
        
        try
            
            id = find(cellfun('isempty', handles.DataContents));
            oran=(length(handles.DataContents)-length(id)+1)/length(handles.DataContents);
            set(handles.progressbar ,'Visible','on')
            if ~isempty(id)
                set(handles.statusText, 'string', ...
                    sprintf('Reading data files ... %d of %d', ...
                    length(handles.DataContents)-length(id)+1, ...
                    length(handles.DataContents)));
                
                set(handles.progressbar, 'position', [.8 0 .2*oran 1]);%,'BackGroundColor');%,[255-oran*254 255 255-oran*255]/255);
                
                
                drawnow;
                handles.DataContents{id(1)} = ...
                    getResisitivityData(...
                    fullfile(get(handles.CurrentDirectoryEdit, 'tooltipstring'), ...
                    handles.DataNames{id(1)}));
                if length(handles.DataContents)==length(handles.DataContents)-length(id)+1
                    set(handles.statusText, 'string', [num2str(length(handles.DataContents)'),' files have been read']);
                    %                     pause(.5)
                end
                fclose all;
            else % All previews are generated. Stop timer
                
                set(handles.FileListBox, 'Enable','on');
                set(handles.progressbar ,'Visible','off')
                stopTimer;
                
            end
            
        catch
            return;
            
        end
        
    end

%--------------------------------------------------------------------------
% getResisitivityData
%   This reads in all supported data files in the current directory
%--------------------------------------------------------------------------
    function record = getResisitivityData(filename)
        [record]=read_data(filename);
    end

%--------------------------------------------------------------------------
% fixLongDirName
%   This truncates the directory string if it is too long to display
%--------------------------------------------------------------------------
    function newdirname = fixLongDirName(dirname)
        % Modify string for long directory names
        if length(dirname) > 20
            [tmp1, tmp2] = strtok(dirname, filesep);
            if isempty(tmp2)
                newdirname = dirname;
                
            else
                % in case the directory name starts with a file separator.
                id = strfind(dirname, tmp2);
                tmp1 = dirname(1:id(1));
                [p, tmp2] = fileparts(dirname);
                if strcmp(tmp1, p) || isempty(tmp2)
                    newdirname = dirname;
                    
                else
                    newdirname = fullfile(tmp1, '...', tmp2);
                    tmp3 = '';
                    while length(newdirname) < 20
                        tmp3 = fullfile(tmp2, tmp3);
                        [p, tmp2] = fileparts(p);
                        if strcmp(tmp1, p)  % reach root directory
                            newdirname = dirname;
                            %break; % it will break because dirname is longer than 30 chars
                            
                        else
                            newdirname = fullfile(tmp1, '...', tmp2, tmp3);
                            
                        end
                    end
                end
            end
        else
            newdirname = dirname;
        end
        
    end

%--------------------------------------------------------------------------
% fileListBoxCallback
%   This gets called when an entry is selected in the file list box
%--------------------------------------------------------------------------
    function fileListBoxCallback(varargin)
        
        obj = varargin{1};
        stopTimer;
        val = get(obj, 'value');
        str = cellstr(get(obj, 'string'));
        
        if ~isempty(str)
            
            switch get(handles.ELRIS, 'selectiontype')
                case 'normal'   % single click - show preview
                    
                    if str{val}(1) == '[' && str{val}(end) == ']'
                        clear_panel(handles)
                        set(findall(gcf,'Tag','info'),'String','')
                    else
                        id = find(handles.DataID == val);
                        if isempty(handles.DataContents{id});
                            handles.DataContents{id} = ...
                                getResisitivityData(...
                                fullfile(...
                                get(handles.CurrentDirectoryEdit, 'tooltipstring'), ...
                                str{val}));
                        end
                        if isstruct(handles.DataContents{id})
                            clear_panel(handles)
                            
                            M=handles.DataContents{id};
                            if M.ip==1
                                set(handles.resip,'Visible','on')
                            else
                                set(handles.resip,'Visible','off')
                            end
                            
                            handles.lastfile=id;
                            handles.moddisp=1;
                            for k=1:4
                                opt(k) = get(handles.(['gosterim',num2str(k)]),'Value');
                            end
                            
                            secgor=get(handles.resip,'Visible');
                            if strcmp(secgor,'on')
                                co=get(handles.resip,'Children');
                                c3=get(co(1),'Value');%which data to display 1: IP 0:Res.
                                switch c3
                                    case 1
                                        optt=opt;
                                        optt(1)=0;
                                        ip_res=1;
                                        pseudo_graph(M,M.ma,optt,handles.MeasResPsd,1,ip_res)
                                    case 0
                                        ip_res=2;
                                        pseudo_graph(M,M.roa,opt,handles.MeasResPsd,1,ip_res)
                                end
                            else
                                ip_res=2;
                                
                                pseudo_graph(M,M.roa,opt,handles.MeasResPsd,1,ip_res)
                            end
                            
                            %Data stats (max and min app.res) (max and min
                            %electrode locations)
                            enkr=min(M.roa);     enbr=max(M.roa);
                            enkk=min(M.xelek);   enbk=max(M.xelek);
                            try
                                dadi=M.filename;dadi(end-3:end)='.mat';
                                N=load(dadi);
                                cek='Yes';
                            catch
                                cek='No';
                            end
                            y1=(sprintf('%7.0f %s % 7.0f ',enkr,'-',enbr));y1(isspace(y1))=[];
                            y2=(sprintf('%7.1f %s % 7.1f ',enkk,'-',enbk));y2(isspace(y2))=[];
                            switch M.ip
                                case 0
                                    ipvar='No';
                                case 1
                                    ipvar='Yes';
                            end
                            
                            SSS={M.eldizc;M.ela;y2;y1;M.nel;max(M.nlev);M.nd;ipvar;cek};
                            for k=1:length(SSS)
                                if mod(k,2)==0
                                    renk=[ 1 1 1];
                                else
                                    renk=bgcolor2+.2;
                                end
                                uicontrol(...
                                    'style'                     , 'text', ...
                                    'foregroundcolor'           , txtcolor, ...
                                    'backgroundcolor'           , renk, ...
                                    'horizontalalignment'       , 'left', ...
                                    'string'                    , SSS(k), ...
                                    'parent'                    , handles.DataInfoPanel, ...
                                    'tag'                       , 'info',...
                                    'units'                     , 'normalized',...
                                    'FontName'                  ,'Verdana',...
                                    'position'                  , [.5 .87 .47 dy ]+[0 -dy*(k-1) 0 0]);
                                %                                         'position'                  , [.025 .87 .5 dy ]+[0 -dy*(k-1) 0 0]);
                                
                            end
                        end
                    end
                    startTimer;
                case 'open'   % double click - Displays measured-calculated data and model if available
                    
                    if str{val}(1) == '[' && str{val}(end) == ']'
                        dirname = get(handles.CurrentDirectoryEdit, 'tooltipstring');
                        newdirname = fullfile(dirname, str{val}(2:end-1));
                        showDirectory(newdirname)
                    else
                        val = get(handles.FileListBox, 'value');
                        nodir=handles.DataID(1)-1;
                        M=handles.DataContents{val-nodir};
                        if M.ip==1
                            set(handles.resip,'Visible','on')
                            
                        else
                            set(handles.resip,'Visible','off')
                        end
                        handles.lastfile=val-nodir;
                        try
                            dadi=handles.DataNames{val-nodir};dadi(end-3:end)='.mat';
                            N=load([handles.lastDir,'\',dadi]);
                            for k=1:4
                                opt(k) = get(handles.(['gosterim',num2str(k)]),'Value');
                            end
                            switch opt(1)
                                case 1
                                    handles.loglin=1;
                                    cizro=log10(N.prho');
                                case 0
                                    handles.loglin=0;
                                    cizro=N.prho';
                            end
                            
                            if M.ip==0
                                pseudo_graph(M,M.roa,opt,handles.MeasResPsd,1,2)
                                pseudo_graph(M,N.ro,opt,handles.CalcResPsd,2,2)
                                %                                 set(handles.CalcResPsd,'XLim',[M.xelek(1) M.xelek(end)])
                                imagemenu_tr_contour(handles);
                                caxis(handles.CalcResPsd,caxis(handles.MeasResPsd))
                                pos1=get(handles.MeasResPsd,'pos');
                                pos2=get(handles.CalcResPsd,'pos');
                                pos2(3)=pos1(3);
                                set(handles.CalcResPsd,'pos',pos2)
                                mod_graph(N.xp,N.zp,cizro,N.alp1,M.xelek,N.iter,N.misfit,M.nel,handles.ModRes) %itmax
                                drawnow;
                            else
                                co=get(handles.resip,'Children');
                                c3=get(co(1),'Value');%which data to display 1: IP 0:Res.
                                if c3==1
                                    opt(1)=0;
                                    pseudo_graph(M,M.ma,opt,handles.MeasResPsd,1,1)
                                    pseudo_graph(M,1000*abs(N.mac),opt,handles.CalcResPsd,2,1)
                                    %                                 set(handles.CalcResPsd,'XLim',[M.xelek(1) M.xelek(end)])
                                    imagemenu_tr_contour(handles);
                                    caxis(handles.CalcResPsd,caxis(handles.MeasResPsd))
                                    pos1=get(handles.MeasResPsd,'pos');
                                    pos2=get(handles.CalcResPsd,'pos');
                                    pos2(3)=pos1(3);
                                    set(handles.CalcResPsd,'pos',pos2)
                                    mod_graph(N.xp,N.zp,1000*N.pma',N.alp1,M.xelek,N.iter,N.misfit_ip,M.nel,handles.ModRes) %itmax
                                    drawnow;
                                else
                                    pseudo_graph(M,M.roa,opt,handles.MeasResPsd,1,2)
                                    pseudo_graph(M,N.ro,opt,handles.CalcResPsd,2,2)
                                    %                                 set(handles.CalcResPsd,'XLim',[M.xelek(1) M.xelek(end)])
                                    imagemenu_tr_contour(handles);
                                    caxis(handles.CalcResPsd,caxis(handles.MeasResPsd))
                                    pos1=get(handles.MeasResPsd,'pos');
                                    pos2=get(handles.CalcResPsd,'pos');
                                    pos2(3)=pos1(3);
                                    set(handles.CalcResPsd,'pos',pos2)
                                    mod_graph(N.xp,N.zp,cizro,N.alp1,M.xelek,N.iter,N.misfit,M.nel,handles.ModRes) %itmax
                                    drawnow;
                                end
                                
                            end
                        catch
                            lasterr
                            set(handles.ModRes,'Visible','off')
                        end
                    end
                    
            end
        end
    end

%--------------------------------------------------------------------------
% chooseDirectoryCallback
%   This opens a directory selector
%--------------------------------------------------------------------------
    function chooseDirectoryCallback(varargin)
        
        stopTimer;
        dirname = uigetdir(get(handles.CurrentDirectoryEdit, 'tooltipstring'), ...
            'Choose Directory');
        clear_panel(handles)
        try
            handles=rmfield(handles,'invert');
            handles=rmfield(handles,'invdata');
        catch
            clc
        end
        
        if ischar(dirname)
            showDirectory(dirname)
        end
    end
%--------------------------------------------------------------------------
%  function to refresh the file list if new files are copied outside MATLAB
%--------------------------------------------------------------------------
    function RefreshDirectoryCallback(varargin)
        dirname=handles.lastDir;
        
        if ischar(dirname)
            showDirectory(dirname)
        end
    end
%--------------------------------------------------------------------------
% upDirectoryCallback
%   This moves up the current directory
%--------------------------------------------------------------------------
    function upDirectoryCallback(varargin)
        set(handles.FileListBox, 'Enable','off');
        stopTimer;
        dirname = get(handles.CurrentDirectoryEdit, 'tooltipstring');
        dirname2 = fileparts(dirname);
        clear_panel(handles)
        try
            handles=rmfield(handles,'invert');
            handles=rmfield(handles,'invdata');
            
        catch
            clc
        end
        if ~isequal(dirname, dirname2)
            showDirectory(dirname2)
        end
        
    end

%--------------------------------------------------------------------------
% startTimer
%   This starts the timer. If the timer object is invalid, it creates a new
%   one.
%--------------------------------------------------------------------------
    function startTimer
        
        try
            if ~strcmpi(handles.tm.Running, 'on');
                start(handles.tm);
            end
            
        catch
            handles.tm          = timer(...
                'name'            , 'image preview timer', ...
                'executionmode'   , 'fixedspacing', ...
                'objectvisibility', 'off', ...
                'taskstoexecute'  , inf, ...
                'period'          , 0.00001, ...
                'startdelay'      , .0001, ...
                'timerfcn'        , @getDataContents);
            start(handles.tm);
        end
    end
%--------------------------------------------------------------------------
% stopTimerFcn
%   This gets called when the figure is closed.
%--------------------------------------------------------------------------
    function stopTimerFcn(varargin)
        
        stop(handles.tm);
        % wait until timer stops
        while ~strcmpi(handles.tm.Running, 'off')
            drawnow;
        end
        delete(handles.tm);
        
    end


%--------------------------------------------------------------------------
% stopTimer
%   This stops the timer object used for generating image previews
%--------------------------------------------------------------------------
    function stopTimer(varargin)
        
        stop(handles.tm);
        
        % wait until timer stops
        while ~strcmpi(handles.tm.Running, 'off')
            drawnow;
        end
        
        set(handles.statusText, 'string', '');
        
    end
    function clear_panel(handles)
        %         delete(findobj('Tag','info'))
        cla(handles.MeasResPsd,'reset');set(handles.MeasResPsd,'Visible','off','FontName','Helvetica','FontSize',11)
        cla(handles.CalcResPsd,'reset');set(handles.CalcResPsd,'Visible','off','FontName','Helvetica','FontSize',11)
        cla(handles.ModRes,'reset');set(handles.ModRes,'Visible','off','FontName','Helvetica','FontSize',11)
        set(handles.MessageText,'String','')
        
    end
    function clear_main_panel(handles)
        
        cla(handles.MeasResPsd,'reset');set(handles.MeasResPsd,'Visible','off','FontName','Helvetica','FontSize',11)
        cla(handles.CalcResPsd,'reset');set(handles.CalcResPsd,'Visible','off','FontName','Helvetica','FontSize',11)
        cla(handles.ModRes,'reset');set(handles.ModRes,'Visible','off','FontName','Helvetica','FontSize',11)
        
        set(handles.MessageText,'String','')
        %         set(handles.gradtext ,'Visible','off')
        
    end
    function snipping(varargin)
        try
            !Snipping Tool.lnk
        catch
            clc
            lasterr
        end
    end
    function savetotext(varargin)
        set(handles.MessageText,'String','Saving to text file');
        
        vis=get(handles.ModRes,'Visible');
        if strcmp(vis,'on')
            val = get(handles.FileListBox, 'value');
            nodir=handles.DataID(1)-1;
            M=handles.DataContents{val-nodir};
            handles.lastfile=val-nodir;
            dadi=handles.DataNames{val-nodir};
            of=dadi(1:end-4);
            dadi(end-3:end)='.mat';
            N=load([handles.lastDir,'\',dadi]);
            x=(N.xp(:,1)+N.xp(:,2))/2;
            z=(N.zp(:,1)+N.zp(:,3))/2;
            rho=N.prho;
            
            fid=fopen([of,'.txt'],'w+');
            fprintf(fid,'%s\n',['Inversion results for file : ',N.data.prfadi]);
            fprintf(fid,'%s\n',['Number of iterations : ',sprintf('%2d',N.iter), '  Data misfit : ',sprintf('%6.2f',N.misfit)]);
            fprintf(fid,'%s\n','1: x and z coordinates of the center of model cells and cell resistivities');
            for k=1:length(rho)
                fprintf(fid,'%7.2f %6.2f %9.2f\n',x(k),z(k),rho(k));
            end
            fprintf(fid,'%s\n','2:  measured, calculated data and misfits, x, mn, n, rhoa_m, rhoa_c,rel_error');
            rltv=100*(M.roa-N.ro)./M.roa;
            for k=1:length(N.ro)
                fprintf(fid,'%7.2f %5.2f %5d %9.2f %9.2f %6.2f\n',M.xd(k),M.mn(k),M.nlev(k),M.roa(k),N.ro(k),rltv(k));
            end
            
        end
        set(handles.MessageText,'String',['Results are written to file : ',[of,'.txt']])
        fclose(fid);
    end
%% ------------------------------------------------------------------------
% Function to save three sections as apdf file. This function only works if
% three sections are displayed on main panel.
%  ------------------------------------------------------------------------

    function captbutton(varargin)
        set(handles.MessageText,'String','Saving to pdf file');
        
        vis=get(handles.ModRes,'Visible');
        if strcmp(vis,'on')
            val = get(handles.FileListBox, 'value');
            nodir=handles.DataID(1)-1;
            fname=handles.DataNames{val-nodir};
            DefaultName=fname(1:end-4);
            M=handles.DataContents{val-nodir};
            
            tempfig=figure('units','normalized','outerposition',[0 0 1 1],'Visible','off');
            dadi=handles.DataNames{val-nodir};
            dadi(end-3:end)='.mat';
            
            N=load([handles.lastDir,'\',dadi]);
            for k=1:4
                opt(k) = get(handles.(['gosterim',num2str(k)]),'Value');
            end
            switch opt(1)
                case 1
                    handles.loglin=1;
                    cizro=log10(N.prho');
                case 0
                    handles.loglin=0;
                    cizro=N.prho';
            end
            ca=caxis(handles.MeasResPsd);
            gorunur=get(handles.resip,'Visible');
            if strcmp(gorunur,'off')
                ciz=2;
                       cipar1=M.roa;
                    cipar2=N.ro;
            else
                co=get(handles.resip,'Children');
                c3=get(co(1),'Value');%which data to display 1: IP 0:Res.
                if c3==1
                    ciz=1;
                    opt(1)=0;
                    cipar1=M.ma;
                    cipar2=1000*N.mac;
                    cizro=1000*N.pma';
                else
                    ciz=2;
                    cipar1=M.roa;
                    cipar2=N.ro;
                end
            end
            h1=subplot(311);
            pseudo(M.xd,M.psd,cipar1,h1,1,opt,M.xelek,M.zelek,ca,ciz)
            
            h2=subplot(312);
            pseudo(M.xd,M.psd,cipar2,h2,2,opt,M.xelek,M.zelek,ca,ciz)
            %                             set(handles.CalcResPsd,'XLim',[M.xelek(1) M.xelek(end)])
            h3=subplot(313);
            mod_graph(N.xp,N.zp,cizro,N.alp1,M.xelek,N.iter,N.misfit,M.nel,h3) %itmax
            try
            if c3
                set(get(gca,'title'),'String',['Model Chargeability Section  Iteration : ',num2str(N.iter), ' ','RMS :',sprintf('%7.2f',N.misfit_ip),' %']);
            end
            end
            set(tempfig,'Visible','off','color','w');
            saveaspdf(gcf,[fname(1:end-4)])
            close(tempfig)
            set(handles.MessageText,'String',['Results are written to file : ',[fname(1:end-4),'.pdf']])
            
        end
        
    end

%% The inversion function -------------------------------------------------

    function invert(varargin)
        val = get(handles.FileListBox, 'value');
        nodir=handles.DataID(1)-1;
        data=handles.DataContents{val-nodir};

        set(handles.InvBut,'Enable','off')
        cocuk=get(handles.resip,'Children');
        secili=get(handles.resip,'SelectedObject');
        kont=get(secili,'String');
        if strcmp(kont,'IP')
            kont2=find(cocuk~=secili);
            set(handles.resip,'SelectedObject',cocuk(2))
        end
        
        % Getting inversion settings
        itmax = (get(handles.numiter,'Value'));
        if itmax==11
            itmax=15;
        end
        for k=1:4
            opt(k) = get(handles.(['gosterim',num2str(k)]),'Value');
        end
        mtype=get(handles.mesh,'value');
        switch mtype
            case 0
                xa=1; za=1;
            case 1
                xa=2; za=1; % divides each cell into half
        end
        if ~isempty(data)
            alfax=1;
            alfaz=1;
            yky=1/data.zmax;%
            %             yky=1/((data.nel-1)*data.ela);
            %             yky=1/data.zmax;
            lambda=std(log(data.roa));
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
            clear_main_panel(handles)
            
            g3 = get(handles.gosterim1,'Value');
            set(handles.progressbar, 'position', [.8 0 0.01 1]);
            set(handles.progressbar ,'Visible','on')
            %
            tic
            
            for iter=1:itmax
                % Forward operator
                
                [J,ro]=forward(yky,t,es,sig,so,data.nel,akel,1,tev,k1,indx,V1,data,prho,npar,par,p);
                dd=log(data.roa(:))-log(ro(:));
                misfit=sqrt((Rd*dd)'*(Rd*dd)/data.nd)*100;
                % Parameter update
                
                [misfit,sig,prho,ro]=pupd(data,J,par,yky,t,es,akel,tev,k1,indx,V1,prho',npar,dd,so,p,C,lambda,Rd);
%                 figure
%                 pdeplot(p,[],t,'xydata',1./sig,'xystyle','flat')
                
                mfit(iter)=misfit;
                switch g3
                    case 0
                        cizro=prho';
                    case 1
                        cizro=log10(prho');
                end
                % Graph the results of iterations
                
                if iter==1
                    alp=sum(abs(J),1);
                    alp=alp/max(alp);
                    alp1=repmat(alp,4,1);
                    alp1=(alp1(:));
                    alp1=alp1+(.91-min(alp1));
                    alp1(alp1>1)=1;
                    mod_graph(xp,zp,cizro,alp1,data.xelek,iter,misfit,data.nel,handles.ModRes)
                    pseudo(data.xd,data.psd,ro,handles.CalcResPsd,2,opt,data.xelek,data.zelek,[],2);
                    pseudo(data.xd,data.psd,data.roa,handles.MeasResPsd,1,opt,data.xelek,data.zelek,[],2);
                    imagemenu_tr_contour(handles);
                    set(handles.MeasResPsd,'XLim',[data.xelek(1) data.xelek(end)])
                    set(handles.CalcResPsd,'XLim',[data.xelek(1) data.xelek(end)])
                    resizeFcn;
                    c=caxis(handles.MeasResPsd);
                    caxis(handles.CalcResPsd,c)
                    drawnow;
                else
                    hh=handles.model;
                    set(hh,'CData',repmat(cizro,4,1))
                    title(handles.ModRes,['Model Resistivity Section',' Iteration : ', num2str(iter),' RMS % = ',sprintf('%5.2f',misfit)]);
                    axpos=get(handles.ModRes,'position');
                    pseudo(data.xd,data.psd,ro,handles.CalcResPsd,2,opt,data.xelek,data.zelek,[],2);
                    set(handles.CalcResPsd,'XLim',[data.xelek(1) data.xelek(end)])
                    c=caxis(handles.MeasResPsd);
                    caxis(handles.CalcResPsd,c)
                    drawnow;
                end
                oran=.2*(1/itmax)*iter;
                set(handles.progressbar, 'position', [.8 0 oran 1]);%,'BackGroundColor',[255-oran*255 255 255-oran*255]/255);
                
                set(handles.statusText, 'string', ...
                    sprintf('Iteration ... %d / %d',iter,itmax))
                drawnow;
                %Stop the inversion if the improvement in the misfit is
                %less than %2.5
                if iter>1
                    farkm=abs(mfit(iter)-mfit(iter-1))./mfit(iter);
                    if farkm<.025
                        break
                    end
                end
                if iter>=2
                    lambda=lambda*.55;
                end
            end
            if data.ip
                [pma,misfit_ip,mac,iterx]=pure_ip(data,ro,sig,J,prho,C,es,akel,V1,k1,so,indx,pma,nu,tev,par,p,t,npar,Rd);
            end
            
            
            itime=toc;
            yer=get(handles.statusText,'position');
            set(handles.statusText, 'string', ...
                [num2str(iter), ' iterations completed in ',sprintf('%5.2f',itime),' seconds.'],'position', [.78, .0, .2 .81]);
            %Enable context menus
            imagemenu_tr_patch(handles);
            imagemenu_tr_contour(handles);
            set(handles.progressbar ,'Visible','off')
            pause(1)
            set(handles.statusText, 'string', '','position',yer)
            % Save inversion results for future display
            dadi=handles.DataNames{val-nodir};
            dadi(end-2:end)='mat';
            if data.ip==0
                save ([handles.lastDir,'\',dadi],'data','xp','zp','prho','misfit','iter','ro','alp1','-mat')
                set(handles.InvBut,'Enable','on')
            else
                save ([handles.lastDir,'\',dadi],'data','xp','zp','prho','misfit','iter','ro','alp1','pma','mac','misfit_ip','-mat')
                set(handles.InvBut,'Enable','on')
                
            end
            
        end
    end

    function imagemenu_tr_patch(varargin)
        %   IMAGEMENU(handle) creates a context menu for patch obejcts
        
        handle = gcf;
        
        handle = findobj(handle, 'type', 'patch');
        
        % Define the context menu
        cmenu = uicontextmenu;
        % Define the context menu items
        uimenu(cmenu, 'Label', 'Reverse color scale', 'Callback', 'colormap(flipud(colormap))');
        uimenu(cmenu, 'Label', 'Length of color scale', 'Callback', @colormaplength);
        uimenu(cmenu, 'Label', 'Color scale limits', 'Callback', @imagelimits1);
        uimenu(cmenu, 'Label', 'Title', 'Callback', @titlecallback);
        uimenu(cmenu, 'Label', 'X-label', 'Callback', @xaxiscallback);
        uimenu(cmenu, 'Label', 'Y-label', 'Callback', @yaxiscallback);
        set(handle, 'uicontextmenu', cmenu);
    end
% Menu callback
    function togglecolorbar(obj, eventdata)
        
        cbar_handle=findobj(gcf,'Tag','colorbar');
        
        g3 = get(obj,'Value');
        switch g3
            case 1
                set(obj,'String','I','backgroundcolor',[179 250 170]/255);
            case 0
                set(obj,'String','O','backgroundcolor',[.8 .8 .8]);
        end
        %         cbar_handle = findobj(gcf,'tag','colorbar');
        for k=1:length(cbar_handle)
            
            durum=get(cbar_handle(k),'Visible');
            switch durum
                case 'on'
                    set(cbar_handle(k),'Visible','off');
                case 'off'
                    set(cbar_handle(k),'Visible','on');
                    %                                         colorbar('on')
                    
            end
        end
    end

% Menu callback
    function colormaplength(obj, eventdata)
        cmap = colormap;
        oldlength = length(cmap);
        clength = cellstr(num2str(oldlength));
        new = inputdlg({'Length of color scale:'}, ...
            '# of samples', 1, clength);
        newlength = str2double(new{1});
        if isnan(newlength)|newlength<8
            newlength=8;
        end
        oldsteps = linspace(0, 1, oldlength);
        newsteps = linspace(0, 1, newlength);
        newmap = zeros(newlength, 3);
        
        for i=1:3
            % Interpolate over RGB spaces of colormap
            newmap(:,i) = min(max(interp1(oldsteps, cmap(:,i), newsteps)', 0), 1);
        end
        colormap(newmap);
        % And update the colorbar, if one exists
        phch = get(findall(gcf,'type','image','tag','TMW_COLORBAR'),{'parent'});
        for i=1:length(phch)
            phud = get(phch{i},'userdata');
            if isfield(phud,'PlotHandle')
                if isequal(gca, phud.PlotHandle)
                    colorbar
                end
            end
        end
    end
% Menu callback
    function imagelimits(obj, eventdata)
        lims = get(gca, 'CLim');
        oldlower = num2str(lims(1));
        oldupper = num2str(lims(2));
        new = inputdlg({'Lower Limit:', 'Upper Limit:'}, ...
            'New data range', 1, {oldlower, oldupper});
        if ~isempty(new)&~isnan(str2double(new{1})) & ~isnan(str2double(new{2}))
            set(handles.MeasResPsd, 'CLim', [str2double(new{1}) str2double(new{2})]);
            set(handles.CalcResPsd, 'CLim', [str2double(new{1}) str2double(new{2})]);
            
        end
        
        % And update the colorbar, if one exists
        phch = get(findall(gcf,'type','image','tag','TMW_COLORBAR'),{'parent'});
        for i=1:length(phch)
            phud = get(phch{i},'userdata');
            if isfield(phud,'PlotHandle')
                if isequal(gca, phud.PlotHandle)
                    colorbar
                end
            end
        end
        
    end
% Menu callback
    function titlecallback(obj, eventdata)
        old = get(gca, 'title');
        oldstring = get(old, 'string');
        if ischar(oldstring)
            oldstring = cellstr(oldstring);
        end
        new = inputdlg('Enter new title:', 'New title', 1, oldstring);
        set(old, 'string', new);
    end
% Menu callback
    function xaxiscallback(obj, eventdata)
        old = get(gca, 'xlabel');
        oldstring = get(old, 'string');
        if ischar(oldstring)
            oldstring = cellstr(oldstring);
        end
        new = inputdlg('Enter new x-label:', 'Change xlabel', 1, oldstring);
        set(old, 'string', new);
    end
% Menu callback
    function yaxiscallback(obj, eventdata)
        old = get(gca, 'ylabel');
        oldstring = get(old, 'string');
        if ischar(oldstring)
            oldstring = cellstr(oldstring);
        end
        new = inputdlg('Enter new y-label:', 'Change ylabel', 1, oldstring);
        set(old, 'string', new);
        
    end
% Callback function for Log scale button

    function tbutton(varargin)
        persistent secim
        if isempty(secim)
            secim=1;%'log';
        end
        g3 = get(handles.gosterim1,'Value');
        
        switch g3
            case 1
                set(handles.gosterim1,'String','I','position',[.02 .05 .96 .9],'backgroundcolor',[179 250 170]/255);
            case 0
                set(handles.gosterim1,'String','O','position',[.02 .05 .96 .9],'backgroundcolor',[.8 .8 .8]);
        end
        switch g3
            case 0
                a=handles.ModRes;
                caxolddata=caxis(handles.MeasResPsd);
                caxoldmodel=caxis(a);
                c=get(a,'Children');
                temp=get(c,'CData');
                
                set(c, 'CData',10.^(temp))
                b=findall(gcf,'type','hggroup');
                for m=1:length(b)
                    temp = double(get(b(m), 'ZData'));
                    set(b(m), 'ZData',10.^(temp))
                    set(b(m),'LevelList',10.^(get(b(m),'LevelList')))%,'auto')
                end
                caxis(handles.MeasResPsd,10.^(caxolddata));
                caxis(handles.CalcResPsd,10.^(caxolddata));
                caxis(a,10.^(caxoldmodel));
                
            case 1
                a=handles.ModRes;
                caxolddata=caxis(handles.MeasResPsd);
                caxoldmodel=caxis(a);
                c=get(a,'Children');
                temp=get(c,'CData');
                set(c, 'CData',log10(temp))
                b=findall(gcf,'type','hggroup');
                for m=1:length(b)
                    temp = double(get(b(m), 'ZData'));
                    set(b(m), 'ZData',log10(temp))
                    set(b(m),'LevelList',log10(get(b(m),'LevelList')))%,'auto')
                end
                caxis(handles.MeasResPsd,log10(caxolddata));
                caxis(handles.CalcResPsd,log10(caxolddata));
                caxis(a,log10(caxoldmodel));
        end
        secim=g3;
    end

    function butcreate(varargin)
        obj=varargin{1};
        
        g3 = get(obj,'Value');
        
        switch g3
            case 1
                set(obj,'String','I','position',[.02 .05 .96 .9],'backgroundcolor',[179 250 170]/255);
                
            case 0
                set(obj,'String','O','position',[.02 .05 .96 .9],'backgroundcolor',[.8 .8 .8]);
                
        end
        
    end
    function imagemenu_tr_contour(varargin)
        %context menu for data sections
        
        handle = gcf;
        
        handle = findobj(handle, 'type', 'hggroup');
        % Define the context menu
        cmenu = uicontextmenu;
        % Define the context menu items
        
        uimenu(cmenu, 'Label', 'Color scale range', 'Callback', @imagelimits);
        uimenu(cmenu, 'Label', 'Title', 'Callback', @titlecallback1);
        uimenu(cmenu, 'Label', 'X-axis label', 'Callback', @xaxiscallback1);
        uimenu(cmenu, 'Label', 'Y-axis label', 'Callback', @yaxiscallback1);
        
        
        
        % And apply menu to handle(s)
        set(handle, 'uicontextmenu', cmenu);
    end
    function togglelines(obj, eventdata)
        
        g3 = get(handles.gosterim2,'Value');
        
        switch g3
            case 1
                set(handles.gosterim2,'String','I','backgroundcolor',[179 250 170]/255);
            case 0
                set(handles.gosterim2,'String','O','backgroundcolor',[.8 .8 .8]);
        end
        a=findall(gcf,'type','hggroup');
        if ~isempty(a)
            lc=get(a,'LineStyle');
            if iscell(lc)
                for k=1:length(lc)
                    kont=cell2mat(lc(k));
                    switch kont
                        case '-'
                            set(a,'LineStyle','none')
                        case 'none'
                            set(a,'LineStyle','-')
                    end
                end
            else
                kont=lc;
                switch kont
                    case '-'
                        set(a,'LineStyle','none')
                    case 'none'
                        set(a,'LineStyle','-')
                end
                
            end
        end
    end

    function toggleelektrot(obj, eventdata)
        g3 = get(obj,'Value');
        
        switch g3
            case 1
                set(obj,'String','I','backgroundcolor',[179 250 170]/255);
            case 0
                set(obj,'String','O','backgroundcolor',[.8 .8 .8]);
        end
        
        a=findall(gcf,'type','hggroup');
        b=findall(gcf,'tag','elektrot');
        % c=get(b,'Visible');
        if ~isempty(b)
            for n=1:length(b)
                switch get(b(n),'Visible')
                    case 'on'
                        set(b(n),'Visible','off')
                    case 'off'
                        set(b(n),'Visible','on')
                end
            end
        else
            M=handles.DataContents{handles.lastfile};
            % hold(handles.MeasResPsd)
            % for i=1:length(a)
            axes(handles.MeasResPsd)
            yl=get(a(1),'YData');
            text(M.xelek,max(yl)*ones(size(M.zelek)),'\downarrow','verticalalignment','bottom','horizontalalignment','center','tag','elektrot','FontSize',8)
            axes(handles.CalcResPsd)
            yl=get(a(1),'YData');
            text(M.xelek,max(yl)*ones(size(M.zelek)),'\downarrow','verticalalignment','bottom','horizontalalignment','center','tag','elektrot','FontSize',8)
        end
    end
    function toggledatax(obj, eventdata)
        g3 = get(obj,'Value');
        switch g3
            case 1
                set(obj,'String','I','backgroundcolor',[179 250 170]/255);
            case 0
                set(obj,'String','O','backgroundcolor',[.8 .8 .8]);
        end
        b=findall(gcf,'tag','nokta');
        if ~isempty(b)
            for n=1:length(b)
                switch get(b(n),'Visible')
                    case 'on'
                        set(b(n),'Visible','off')
                    case 'off'
                        set(b(n),'Visible','on')
                end
            end
        end
    end


    function callbackcont(obj, eventdata)
        
        g3 = get(obj,'Value');
        switch g3
            case 1
                set(obj,'position',[.48 .0375 .5 .9]);
            case 0
                set(obj,'position',[0.02 .0375 .5 .9]);
        end
    end
    function callbackmesh(obj, eventdata)
        
        g3 = get(obj,'Value');
        switch g3
            case 1
                set(obj,'String','Normal');
            case 0
                set(obj,'String','Fine');
        end
    end
    function callbackbright(obj,eventdata)
        g3 = get(obj,'String');
        switch g3
            case '<'
                brighten(-.075)
            case '>'
                brighten(.075)
        end
        
        
    end

    function colormaplength1(obj, eventdata)
        cmap = colormap;
        oldlength = length(cmap);
        clength = cellstr(num2str(oldlength));
        new = inputdlg({'Color scale length:'}, ...
            '# of color stpes', 1, clength);
        newlength = str2double(new{1});
        oldsteps = linspace(0, 1, oldlength);
        newsteps = linspace(0, 1, newlength);
        newmap = zeros(newlength, 3);
        
        for i=1:3
            % Interpolate over RGB spaces of colormap
            newmap(:,i) = min(max(interp1(oldsteps, cmap(:,i), newsteps)', 0), 1);
        end
        colormap(newmap);
        % And update the colorbar, if one exists
        phch = get(findall(gcf,'type','image','tag','TMW_COLORBAR'),{'parent'});
        for i=1:length(phch)
            phud = get(phch{i},'userdata');
            if isfield(phud,'PlotHandle')
                if isequal(gca, phud.PlotHandle)
                    colorbar
                end
            end
        end
    end
% Menu callback
    function imagelimits1(obj, eventdata)
        lims = get(gca, 'CLim');
        oldlower = num2str(lims(1));
        oldupper = num2str(lims(2));
        new = inputdlg({'Color data min:', 'Color data max:'}, ...
            'Modify color range', 1, {oldlower, oldupper});
        if ~isnan(str2double(new{1})) & ~isnan(str2double(new{2}))
            set(gca, 'CLim', [str2double(new{1}) str2double(new{2})]);
        end
        
        % And update the colorbar, if one exists
        phch = get(findall(gcf,'type','image','tag','TMW_COLORBAR'),{'parent'});
        for i=1:length(phch)
            phud = get(phch{i},'userdata');
            if isfield(phud,'PlotHandle')
                if isequal(gca, phud.PlotHandle)
                    colorbar
                end
            end
        end
    end
% Menu callback
    function titlecallback1(obj, eventdata)
        old = get(gca, 'title');
        oldstring = get(old, 'string');
        if ischar(oldstring)
            oldstring = cellstr(oldstring);
        end
        new = inputdlg('New title:', 'Modify axes title', 1, oldstring);
        if ~isempty(new)
            
            set(old, 'string', new);
        end
    end
% Menu callback
    function xaxiscallback1(obj, eventdata)
        old = get(gca, 'xlabel');
        oldstring = get(old, 'string');
        if ischar(oldstring)
            oldstring = cellstr(oldstring);
        end
        new = inputdlg('Enter new x-label:', 'Modify x-axis label', 1, oldstring);
        if ~isempty(new)
            
            set(old, 'string', new);
        end
    end
% Menu callback
    function yaxiscallback1(obj, eventdata)
        old = get(gca, 'ylabel');
        oldstring = get(old, 'string');
        if ischar(oldstring)
            oldstring = cellstr(oldstring);
        end
        new = inputdlg('Enter new y-label:', 'Modify y-axis label', 1, oldstring);
        if ~isempty(new)
            
            set(old, 'string', new);
        end
        
    end

    function callbackcolor(obj, eventdata)
        renk=get(obj,'tag');
        try
            cptcmap(['GMT_',renk],'ncol',128);
        catch
            try
                colormap(renk)
            catch
                colormap(othercolor(renk));
            end
        end
        
    end
% Pseudosection plotting
    function pseudo(xd,psd,ro,data_axes,sec,opt,xelek,zelek,ca,ip_res)
        
        [xc,yc]=meshgrid(unique(xd),unique(psd));
        %         F = TriScatteredInterp((xd(:)),psd(:),ro(:));
        
        %         zT = F(xc,yc);
        zT=griddata((xd(:)),psd(:),ro,xc,yc,'natural');
        if opt(1)==1
            zT=log10(zT);
        end
        if opt(2)==0
            linestyle='none';
        elseif opt(2)==1
            linestyle='-';
        end
        fn='Microsoft Sans Serif';
        fs=11;
        
        contourf(data_axes,unique(xd),unique(psd),(zT),20,'LineStyle',linestyle,'tag','log');
        
        xlabel(data_axes,'Distance (m)','FontName',fn,'FontSize',fs)
        ylabel(data_axes,'Pseudo-Depth (m)','FontName',fn,'FontSize',fs)
        
        
        hold(data_axes,'on')
        hn=plot(data_axes,xd,psd,'. k','MarkerSize',2,'Tag','nokta');
        
        if opt(4)==1
            set(hn,'Visible','on');
        elseif opt(4)==0
            set(hn,'Visible','off');
            
        end
        
        yl=get(data_axes,'YLim');
        
        hold(data_axes,'off')
        axpos=get(data_axes,'position');
        ca1=caxis(data_axes);
        if isempty(ca)
            ca=ca1;
        end
        if ca1~=ca
            caxis(data_axes,ca);
        end
        h=colorbar('peer',data_axes,'Location','eastoutside','FontName',fn,'FontSize',fs,'tag','colorbar','Visible','off');
        switch ip_res
            case 1
                tit='Apparent Chargeability';
            case 2
                tit='Apparent Resistivity';
        end
        switch sec
            case 1
                title(data_axes,['Measured ',tit,' Pseudosection'],'FontName',fn,'FontSize',fs,'units','normalized','position',[(axpos(1)+axpos(3))/1.65 axpos(2)+axpos(4)+.15 0 ]);%,'FontName',df)
            case 2
                title(data_axes,['Calculated ',tit,' Pseudosection'],'FontName',fn,'FontSize',fs,'units','normalized','position',[(axpos(1)+axpos(3))/1.65 axpos(2)+axpos(4)+.45 0 ]);%,'FontName',df)
        end
        set(data_axes,'FontName',fn)
        switch opt(3)
            case 1
                axes(data_axes);
                text(xelek,max(yl)*ones(size(zelek)),'\downarrow','verticalalignment','bottom','horizontalalignment','center','tag','elektrot','fontSize',8)
            case 0
                elhand=findall(data_axes,'Tag','elektrot');
                set(elhand,'Visible','off')
        end
        
        
    end
% Graph the model
    function mod_graph(xp,zp,cizro,alp1,xelek,iter,misfit,nel,ax)
        %         axes(handles.ModRes);
        axes(ax);
        
        deffont='Microsoft Sans Serif';
        hh=patch(xp',zp',repmat(cizro,4,1),'tag','model');
        handles.model=hh;
        set(hh,'EdgeColor',[170 170 170]/255)
        
        %                 set(hh,'EdgeAlpha',.8)
        alpha(hh,alp1)
        z=unique(zp(:));
        
        for k=1:length(z)
            ZL{k}=sprintf('%6.1f',z(k));
        end
        set(gca,'XLim',[xelek(1)-.01 xelek(end)],'XTick',xelek(1:2:end))
        set(gca,'YLim',[min(zp(:))-.01 max(zp(:))],'YTick',sort(z),'YTickLabel',(ZL))
        if length(z)>8
            set(gca,'FontSize',9)
        else
            set(gca,'FontSize',11)
        end
        
        hpa=colorbar('peer',gca,'Location','eastoutside','FontName',deffont,'tag','colorbar');
        handles.hpa=hpa;
        xlabel('Distance (m)','FontName',deffont,'FontSize',11);
        ylabel('Depth (m)','FontName',deffont,'FontSize',11);
        title(['Model Resistivity Section  ','Iteration : ',num2str(iter),' RMS = ',sprintf('%5.2f',misfit),' %'] ,'FontName',deffont,'FontSize',11);
        if ax==handles.ModRes
            set(handles.ModRes,'Visible','on');
        end
        
        imagemenu_tr_patch(handles);
        h(1)=xlabel('Distance (m)','FontName',deffont,'FontSize',11);
        h(2)=ylabel('Depth (m)','FontName',deffont,'FontSize',11);
        h(3)=title(['Model Resistivity Section  ','Iteration : ',num2str(iter),' RMS = ',sprintf('%5.2f',misfit),' %'] ,'FontName',deffont,'FontSize',11);
        resizeFcn;
        % enlarge;
        
        
        
    end


    function closefcn(obj, eventdata)
        fclose all;
        close(obj)
        clc;
    end
    function enlarge(varargin)
        durum=get(gco,'Value');
        if durum==0
            set(figH, 'units', 'pixels');
            figPos = get(figH, 'position');
            
            %         figure can't be too small or off the screen
            if figPos(3) < 1024 || figPos(4) < 768
                figPos(3) = max([1024 figPos(3)]);
                figPos(4) = max([768 figPos(4)]);
                screenSize = get(0, 'screensize');
                if figPos(1)+figPos(3) > screenSize(3)
                    figPos(1) = screenSize(3) - figPos(3) - 50;
                end
                if figPos(2)+figPos(4) > screenSize(4)
                    figPos(2) = screenSize(4) - figPos(4) - 50;
                end
                
                set(figH, 'position', figPos);
                
            end
            set(handles.MainPanel            , 'position', [290, 40, figPos(3)-400, figPos(4)-50]);
            hidelist=[handles.VisSetPanel,handles.ColSetPanel,handles.toolspan,handles.titlepanel6,handles.titlepanel5,handles.titlepanel4];
            set(hidelist,'Visible','on')
            set(gco,'String','>','tooltipstring','Enlarge panel')
        elseif durum==1
            set(figH, 'units', 'pixels');
            figPos = get(figH, 'position');
            
            %         figure can't be too small or off the screen
            if figPos(3) < 1024 || figPos(4) < 768
                figPos(3) = max([1024 figPos(3)]);
                figPos(4) = max([768 figPos(4)]);
                screenSize = get(0, 'screensize');
                if figPos(1)+figPos(3) > screenSize(3)
                    figPos(1) = screenSize(3) - figPos(3) - 50;
                end
                if figPos(2)+figPos(4) > screenSize(4)
                    figPos(2) = screenSize(4) - figPos(4) - 50;
                end
                
                set(figH, 'position', figPos);
            end
            set(handles.MainPanel            , 'position', [290, 40, figPos(3)-305, figPos(4)-50]);
            
            hidelist=[handles.VisSetPanel,handles.ColSetPanel,handles.toolspan,handles.titlepanel6,handles.titlepanel5,handles.titlepanel4];
            set(hidelist,'Visible','off')
            set(gco,'String','<','tooltipstring','Show tools panel')
        end
    end
    function res_ip_switch(varargin)
        co=get(handles.resip,'Children');
        c3=get(co(1),'Value');%which data to display 1: IP 0:Res.
       
        M=handles.DataContents{handles.lastfile};
        ismgor=get(handles.ModRes,'Visible');
        for k=1:4
            opt(k) = get(handles.(['gosterim',num2str(k)]),'Value');
        end
        if strcmp(ismgor,'on')
            c=1;
        else
            c=0;
        end
        if c3==1&c==0 % IP data to display no model
            opt(1)=0;
            pseudo_graph(M,M.ma,opt,handles.MeasResPsd,1,1)
            imagemenu_tr_contour(handles);
            
        elseif c3==0&c==0 %Resistivity Data to display no model
            for k=1:4
                opt(k) = get(handles.(['gosterim',num2str(k)]),'Value');
            end
            pseudo_graph(M,M.roa,opt,handles.MeasResPsd,1,2)
            imagemenu_tr_contour(handles);
            
        elseif c3==0&c==1 % REs. data and model to display
            a=get(handles.MeasResPsd);
            b=get(a.Title);
            if ~strcmp(b,'Measured Apparent Resistivity Pseudosection')
                for k=1:4
                    opt(k) = get(handles.(['gosterim',num2str(k)]),'Value');
                end
                pseudo_graph(M,M.roa,opt,handles.MeasResPsd,1,2)
                dadi=handles.DataNames{handles.lastfile};dadi(end-3:end)='.mat';
                N=load([handles.lastDir,'\',dadi]);
                pseudo_graph(M,N.ro,opt,handles.CalcResPsd,2,2)
                imagemenu_tr_contour(handles);
                
                
                switch opt(1)
                    case 1
                        handles.loglin=1;
                        cizro=log10(N.prho');
                    case 0
                        handles.loglin=0;
                        cizro=N.prho';
                end
                a=handles.ModRes;
                c=get(a,'Children');
                temp=get(c,'CData');
                cc=repmat(cizro,4,1);
                set(c, 'CData',cc)
                h(3)=title(a,['Model Resistivity Section  ','Iteration : ',num2str(N.iter),' RMS = ',sprintf('%5.2f',N.misfit),' %'] ,'FontName',deffont,'FontSize',11);
            end
        elseif c3==1&c==1 % IP Data& Model to display
            a=get(handles.MeasResPsd);
            b=get(a.Title);
            if ~strcmp(b,'Measured Apparent Chargeability Pseudosection')
                for k=1:4
                    opt(k) = get(handles.(['gosterim',num2str(k)]),'Value');
                end
                
                cla(handles.MeasResPsd)
                pseudo_graph(M,M.ma,[0 opt(2:end)],handles.MeasResPsd,1,1)
                caxis(handles.MeasResPsd,'auto')
                ca=caxis(handles.MeasResPsd);
                dadi=handles.DataNames{handles.lastfile};dadi(end-3:end)='.mat';
                N=load([handles.lastDir,'\',dadi]);
                pseudo_graph(M,1000*N.mac,[0 opt(2:end)],handles.CalcResPsd,2,1)
                caxis(handles.CalcResPsd,ca);
                a=handles.ModRes;
                c=get(a,'Children');
                temp=get(c,'CData');
                cizro=repmat(1000*N.pma',4,1);
                set(c, 'CData',cizro)
                h(3)=title(a,['Model Chargeability Section  ','Iteration : ',num2str(N.iter),' RMS = ',sprintf('%5.2f',N.misfit_ip),' %'] ,'FontName',deffont,'FontSize',11);
                imagemenu_tr_contour(handles);
            end
        end
        
    end
    function pseudo_graph(M,d,opt,ax,m_c,ip_res)
        if strcmp(M.eldizc,'Pole-Dipole')||strcmp(M.eldizc,'Dipole-Dipole')||strcmp(M.eldizc,'Schlumberger')||strcmp(M.eldizc,'Wenner')||strcmp(M.eldizc,'Pol-Pol')
            pseudo(M.xd,M.psd,d,ax,m_c,opt,M.xelek,M.zelek,[],ip_res)
            
            set(ax,'XLim',[M.xelek(1) M.xelek(end)])
            
        end
    end


end

