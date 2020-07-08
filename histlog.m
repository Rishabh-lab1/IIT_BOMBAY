function [no,xo] = histlog(y,x)
%HISTLOG Histogram with log scale.
%
% Same as hist.m but calls barlog.m instead of bar.m
%
%N = HIST(Y) bins the elements of Y into 10 equally spaced containers
% and returns the number of elements in each container. If Y is a
% matrix, HIST works down the columns.
%
% N = HIST(Y,M), where M is a scalar, uses M bins.
%
% N = HIST(Y,X), where X is a vector, returns the distribution of Y
% among bins with centers specified by X.
%
% [N,X] = HIST(...) also returns the position of the bin centers in X.
%
% HIST(...) without output arguments produces a histogram bar plot of
% the results.

% J.N. Little 2-06-86
% Revised 10-29-87, 12-29-88 LS
% Revised 8-13-91 by cmt, 2-3-92 by ls.
% Copyright (c) 1984-96 by The MathWorks, Inc.
% $Revision: 5.9 $ $Date: 1996/10/25 17:55:58 $

if nargin == 0
    error('Requires one or two input arguments.')
end
if nargin == 1
    x = 10;
end
if min(size(y))==1, y = y(:); end
if isstr(x) | isstr(y)
    error('Input arguments must be numeric.')
end
[m,n] = size(y);
if length(x) == 1
    miny = min(min(y));
    maxy = max(max(y));
    binwidth = (maxy - miny) ./ x;
    xx = miny + binwidth*(0:x);
    xx(length(xx)) = maxy;
    x = xx(1:length(xx)-1) + binwidth/2;
else
    xx = x(:)';
    miny = min(min(y));
    maxy = max(max(y));
    binwidth = [diff(xx) 0];
    xx = [xx(1)-binwidth(1)/2 xx+binwidth/2];
    xx(1) = miny;
    xx(length(xx)) = maxy;
end
nbin = length(xx);
nn = zeros(nbin,n);
for i=2:nbin
    nn(i,:) = sum(y <= xx(i));
end
nn = nn(2:nbin,:) - nn(1:nbin-1,:);
if nargout == 0
    barlog(x,nn,'hist');
else
  if min(size(y))==1, % Return row vectors if possible.
    no = nn';
    xo = x;
  else
    no = nn;
    xo = x';
  end
end

%ok here is the second part, barlog.m

function [xo,yo] = barlog(varargin)
%BARLOG Bar graph.
%
% Modified version of bar.m by M. Banta, 7/11/97 to use a log y scale
%
% BAR(X,Y) draws the columns of the M-by-N matrix Y as M groups of N
% vertical bars. The vector X must be monotonically increasing or
% decreasing.
%
% BAR(Y) uses the default value of X=1:M. For vector inputs, BAR(X,Y)
% or BAR(Y) draws LENGTH(Y) bars. The colors are set by the colormap.
%
% BAR(X,Y,WIDTH) or BAR(Y,WIDTH) specifies the width of the bars. Values
% of WIDTH > 1, produce overlapped bars. The default value is WIDTH=0.8
%
% BAR(...,'grouped') produces the default vertical grouped bar chart.
% BAR(...,'stacked') produces a vertical stacked bar chart.
% BAR(...,LINESPEC) uses the line color specified (one of 'rgbymckw').
%
% H = BAR(...) returns a vector of patch handles.
%
% Examples: subplot(3,1,1), bar(rand(10,5),'stacked'), colormap(cool)
% subplot(3,1,2), bar(0:.25:1,rand(5),1)
% subplot(3,1,3), bar(rand(2,3),.75,'grouped')
%
% See also HIST, PLOT, BARH.

% C.B Moler 2-06-86
% Modified 24-Dec-88, 2-Jan-92 LS.
% Modified 8-5-91, 9-22-94 by cmt; 8-9-95 WSun.
% Copyright (c) 1984-96 by The MathWorks, Inc.
% $Revision: 5.24 $ $Date: 1996/10/25 17:43:37 $

error(nargchk(1,4,nargin));

[msg,x,y,xx,yy,linetype,plottype,barwidth,equal] = makebars(varargin{:});
if ~isempty(msg), error(msg); end

if nargout==2,
  warning(sprintf(...
     ['BAR with two output arguments is obsolete. Use H = BAR(...) \n',...
      ' and get the XData and YData properties instead.']))
  xo = xx; yo = yy; % Do not plot; return result in xo and yo
else % Draw the bars
  cax = newplot;
  next = lower(get(cax,'NextPlot'));
  hold_state = ishold;
  edgec = get(gcf,'defaultaxesxcolor');
  facec = 'flat';
  h = []; 
  cc = ones(size(xx,1),1);
  if ~isempty(linetype), facec = linetype; end
  for i=1:size(xx,2)
    numBars = (length(xx)-1)/5;
    for j=1:numBars,
       f(j,:) = (2:5) + 5*(j-1);
    end

    v = [xx(:,i) yy(:,i)];
    h_me=[];
    for i_me=[1:length(v)]
    	if v(i_me,2) ~= 0
    	v(i_me,2)=log10(v(i_me,2));
    	h_me=[h_me v(i_me,2)];
    	end
    end
    diff_me=max(h_me)-min(h_me);
    ylim_me(1)=-0.05;
    ylim_me(2)=ceil(max(h_me))+0.1;
    tick_me=[];
    index_me=0;
    for i_me=[0:ylim_me(2)+5]
    	tick_me=[tick_me i_me];
    	for j_me=[2:9]
    	tick_me=[tick_me (log10(j_me)+i_me)];
    	end
    end
    for i_me=tick_me
if i_me > ylim_me(1) & i_me < ylim_me(2)
if round(i_me)==i_me
index_me=index_me+1;
label_me{index_me}=sprintf('%0.4g',10.^i_me);
else
index_me=index_me+1;
label_me{index_me}=' ';
end
end
    end	
    set(cax,'YLim',ylim_me)
    h=[h patch('faces', f, 'vertices', v, 'cdata', i*cc, ...
        'FaceColor',facec,'EdgeColor',edgec)];
    set(cax,'YTickMode','manual')
    set(cax,'Ytick',tick_me) 
    set(cax,'YTickLabelMode','manual')
    set(cax,'YTickLabel',label_me)
    lim_me=get(cax,'Ylim');
    rat_me=(max(lim_me)-min(lim_me));
    lim_me(1)=lim_me(1)-rat_me/110;
    lim_me(2)=round(lim_me(2))+rat_me;
% set(cax,'Ylim',lim_me)
  end
  if length(h)==1, set(cax,'clim',[1 2]), end
  if ~equal, 
    hold on,
    plot(x(:,1),zeros(size(x,1),1),'*')
  end
  if ~hold_state, 
    % Set ticks if less than 16 integers
    if all(all(floor(x)==x)) & (size(x,1)<16), 
      set(cax,'xtick',x(:,1))
    end
    hold off, view(2), set(cax,'NextPlot',next);
    set(cax,'Layer','Bottom','box','on')
  end
  if nargout==1, xo = h; end
end