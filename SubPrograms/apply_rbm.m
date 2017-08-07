function [UXfinal,UYfinal,UZfinal,rbma]=apply_rbm(POSX,POSY,POSZ,rbm_input,UXref,UYref,UZref)
% APPLY_RBM Applies the rigid body motion in rbma
% y = R*x + t
% if UXref, UYre and UZref are not speficied then they are taken as zeros,
% i.e. outputs UXf,UYf,UZf are only rigid motion fields
% RBMA is the affine/augmented rigid body transformation, and is a 3-by-2
% array:
% RBMA = [ a b c j
%          d e f k
%          g h i l
%          0 0 0 1];
% j k l are rigid body parameters

% RBM is the short version of RBMA
% Input can be:
% RBM = [a d
%        b e
%        c f]
% a,b,c are angles for rotation about x,y,z axes, and d,e,f, are rigid body
% translation values in x,y,z directions.
% RBM 3-by-2 is always converted to RBMA 4-by-4. See immediately below.
% RBMVEC is a 6-by-1 vector of rotation x,y,z, rotations (1:3), and
% translations (4:end). see **
% Note: RBM=reshape(RBMVEC,3,2);
% ROT_MAT is a 3-by-3 rotation matrix.

% %% example
% clearvars
% POSX=0;
% POSY=0;
% POSZ=4;
% UXref=0;
% UYref=0;
% UZref=1;
% rbm_input(1,1)=0.01;
% rbm_input(2,1)=0.02;
% rbm_input(3,1)=0.03;
% rbm_input=randn(6,1)*20
% % rbm_input(1,2)=0;
% % rbm_input(2,2)=0;
% % rbm_input(3,2)=0;

% Convert RBMVEC ? RBM and ROT_MAT (rotation matrix)
if numel(rbm_input)<9
    rbmvec=rbm_input(:);
    if length(rbmvec)==3
        rbmvec(6)=0;
    end
    rot_mat=rotz(rbmvec(3))*roty(rbmvec(2))*rotx(rbmvec(1));
    rbd=rbmvec(4:end); % rigid body displacements
elseif numel(rbm_input)==9
    rot_mat=rbm_input;
    rbmvec=zeros(6,1);
    rbmvec(1:3)=nan;
elseif numel(rbm_input)==16
    rot_mat=rbm_input(1:3,1:3);
    rbd=rbm_input(1:end-1,end);
    rbmvec=nan(6,1);
    rbmvec(4:end)=rbd;
else
    error('incorrect numel(rbm_input)');
end

% Convert RBM and ROT_MAT (rotation matrix) ? RBMA
if numel(rbm_input)~=16
    rbma=[rot_mat,[rbd(1);rbd(2);rbd(3)]]; % rotation matrix
    rbma(4,4)=1;
elseif numel(rbm_input)==16
    rbma=rbm_input;
    disp('Nice! - rbm already in affine transformation (rbma) format.')
else
    error('rbm_input is the wrong size or has the wrong number of elements.')
end

%% Mahmouds code:
%     rot_mat = [cos(rbm(2,1))*cos(rbm(3,1)), sin(rbm(1,1))*sin(rbm(2,1))*cos(rbm(3,1))-cos(rbm(1,1))*sin(rbm(3,1)), cos(rbm(1,1))*sin(rbm(2,1))*cos(rbm(3,1))+sin(rbm(1,1))*sin(rbm(3,1));...
%         cos(rbm(2,1))*sin(rbm(3,1)), sin(rbm(1,1))*sin(rbm(2,1))*sin(rbm(3,1))+cos(rbm(1,1))*cos(rbm(3,1)), cos(rbm(1,1))*sin(rbm(2,1))*sin(rbm(3,1))-sin(rbm(1,1))*cos(rbm(3,1));...
%         -sin(rbm(2,1)),                                           sin(rbm(1,1))*cos(rbm(2,1)),                                          cos(rbm(1,1))*cos(rbm(2,1))]


% Create RBM fields: rotation + translation
POSX2=rot_mat(1,1)*POSX + rot_mat(1,2)*POSY + rot_mat(1,3)*POSZ;
POSY2=rot_mat(2,1)*POSX + rot_mat(2,2)*POSY + rot_mat(2,3)*POSZ;
POSZ2=rot_mat(3,1)*POSX + rot_mat(3,2)*POSY + rot_mat(3,3)*POSZ;
UXfinal= (POSX2-POSX) + rbmvec(4);
UYfinal= (POSY2-POSY) + rbmvec(5);
UZfinal= (POSZ2-POSZ) + rbmvec(6);
% UXfinal= -(POSX2-POSX) - rbmvec(4);
% UYfinal= -(POSY2-POSY) - rbmvec(5);
% UZfinal= -(POSZ2-POSZ) - rbmvec(6);

% % Output original fields shifted if refreence fields are in the input
% if exist('UXref','var')
%     UXfinal= UXref - UXfinal;
%     UYfinal= UYref - UYfinal;
%     UZfinal= UZref - UZfinal;
% end

if exist('UXref','var')
    UXfinal= -UXref + UXfinal;
    UYfinal= -UYref + UYfinal;
    UZfinal= -UZref + UZfinal;
end

%% example
% pythag(POSX,POSY,POSZ)
% pythag(POSX2,POSY2,POSZ2)
% pythag(POSX+UXref,POSY+UYref,POSZ+UZref);
% meshcc(UXref,UXfinal);
end


