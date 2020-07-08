function [Rd,Rs,Rx,Rz,Rxx]=adaptive_lp(Wd,Ws,Wx,Wz,C,dobs,d,J,m,dm,p,epsilon)

Xd = Wd*(dobs-d-J*dm);
Xs=Ws*(m+dm);
Xx=Wx*(m+dm);
Xz=Wz*(m+dm);
Xxx=C*(m+dm);
Rd=diag(p*(Xd.^2+epsilon^2).^((p/2)-1));
Rs=diag(p*(Xs.^2+epsilon^2).^((p/2)-1));
Rx=diag(p*(Xx.^2+epsilon^2).^((p/2)-1));
Rz=diag(p*(Xz.^2+epsilon^2).^((p/2)-1));
Rxx=diag(p*(Xxx.^2+epsilon^2).^((p/2)-1));
%RI=diag(log(p*(Xi.^2+epsilon^2).^((p/2)-1)));
end