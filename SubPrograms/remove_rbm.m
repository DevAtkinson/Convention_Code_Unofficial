function [UXfin,UYfin,UZfin,rbma_final]=remove_rbm(POSX,POSY,POSZ,UX1,UY1,UZ1,UX0,UY0,UZ0)

% if optional reference field wasn't given
if ~exist('UX0','var')
    UX0=zeros(size(POSX));
    UY0=zeros(size(POSX));
    UZ0=zeros(size(POSX));
end

[r,c]=size(POSX);
POSX=reshape(POSX,[r*c,1]);
POSY=reshape(POSY,[r*c,1]);
POSZ=reshape(POSZ,[r*c,1]);
uX=reshape(UX1,[r*c,1]);
uY=reshape(UY1,[r*c,1]);
uZ=reshape(UZ1,[r*c,1]);
UX0=reshape(UX0,[r*c,1]);
UY0=reshape(UY0,[r*c,1]);
UZ0=reshape(UZ0,[r*c,1]);
data3D_col=[POSX,POSY,POSZ,uX,uY,uZ];
goodidx=~any(isnan(data3D_col),2);
POSX=POSX(goodidx);
POSY=POSY(goodidx);
POSZ=POSZ(goodidx);
UX1=uX(goodidx);
UY1=uY(goodidx);
UZ1=uZ(goodidx);
UX0=UX0(goodidx);
UY0=UY0(goodidx);
UZ0=UZ0(goodidx);



tic
% optoptions=optimset('TolX',1e-18,'MaxFunEvals',1e18,'MaxIter',1e18);
% errorf=@(rbmf) rbm_costfunc_fif(POSX,POSY,POSZ,UX1,UY1,UZ1,rbmf,UX0,UY0,UZ0);
% rbm0=randn(6,1);
% rbm_final = fminsearch(errorf,rbm0,optoptions);


options2 = optimoptions('lsqnonlin','MaxFunEval',1e4,'MaxIter',1e12,'TolFun',1e-10,'Display','final','TolX',1e-6); %'Algorithm','sqp'
errorf=@(rbmf) rbm_costfunc_lsq_fif(POSX,POSY,POSZ,UX1,UY1,UZ1,rbmf,UX0,UY0,UZ0);
rbm0=randn(6,1);
[rbm_final,~] = lsqnonlin(errorf,rbm0,[-2*pi;-2*pi;-2*pi;-1000;-1000;-1000],[2*pi;2*pi;2*pi;1000;1000;1000],options2);

toc

[UXfinal,UYfinal,UZfinal,rbma_final]=apply_rbm(POSX,POSY,POSZ,rbm_final);

UXfinal= -(UX1 - UXfinal);
UYfinal= -(UY1 - UYfinal);
UZfinal= -(UZ1 - UZfinal);
uX(goodidx)=UXfinal;
uY(goodidx)=UYfinal;
uZ(goodidx)=UZfinal;
UXfin=reshape(uX,[r,c]);
UYfin=reshape(uY,[r,c]);
UZfin=reshape(uZ,[r,c]);


end

function error=rbm_costfunc_fif(POSX,POSY,POSZ,UX1,UY1,UZ1,rbma,UX0,UY0,UZ0)
[UXf,UYf,UZf]=apply_rbm(POSX,POSY,POSZ,rbma,UX1,UY1,UZ1); % move 1 ? 0
% [UXf,UYf,UZf]=apply_rbm(POSX,POSY,POSZ,rbma,UX0,UY0,UZ0);
error=nansum((UXf(:)-UX0(:)).^2 + (UYf(:)-UY0(:)).^2 + (UZf(:)-UZ0(:)).^2);
end

function error=rbm_costfunc_lsq_fif(POSX,POSY,POSZ,UX1,UY1,UZ1,rbma,UX0,UY0,UZ0)
[UXf,UYf,UZf]=apply_rbm(POSX,POSY,POSZ,rbma,UX1,UY1,UZ1);
% [UXf,UYf,UZf]=apply_rbm(POSX,POSY,POSZ,rbma,UX0,UY0,UZ0);
error=((UXf(:)-UX0(:)).^2 + (UYf(:)-UY0(:)).^2 + (UZf(:)-UZ0(:)).^2);
end

