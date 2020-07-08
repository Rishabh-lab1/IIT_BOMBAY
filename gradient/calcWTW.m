function[ Gs,Gx,Gz] = calcWTW(dx,dz)
% [WTW] = calcWTW(MTX,wt)
% Calculate WTW - the model regularization matrix
% USE: grad, kron3

% Copyright (c) 2007 by the Society of Exploration Geophysicists.
% For more information, go to http://software.seg.org/2007/0001 .
% You must read and accept usage terms at:
% http://software.seg.org/disclaimer.txt before use.
% 
% Revision history:
% Original SEG version by Adam Pidlisecky and Eldad Haber
% Last update, July 2005


%smoothing parameters for the three directions large number promotes flatness in given direction dlz big makes things vertical
alx = 1;
alz = 1;

%Smallness parameter
als = 0.1;

nx=length(dx);
nz=length(dz);

[G,Gx,Gz] = grad2d(dx,dz);


%%Create a weighted smallness term 
wt=ones(nx*nz,1);
Gs = spdiags(mkvc(wt), nx*nz, nx*nz); 

%Assemble the Anisotropic gradient operrator
%Gs = [alx*Gx;alz*Gz];

%Weights certain points more than others
%Wt = spdiags(mkvc(wt),nx*nz,nx*nz);


%assemble the 3d weighting matrix
%WTW = Wt' * ( Gs' * Gs + als * V) * Wt;



