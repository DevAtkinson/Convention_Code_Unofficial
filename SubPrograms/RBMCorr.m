function [PX,PY,PZ,UX,UY,UZ,eulerAngles,rotCentre,RBD] = RBMCorr(PX,PY,PZ,UX,UY,UZ)
% RBMCORR removes the 3D rigid body motions (translation and rotation from
%     a volumetric dataset (e.g. from DVC). The algorithm for rotation
%     removal is based on Ken Shoemake's Euler angle correction.
%
% Inputs:
%     dat3D_col       6 column data as [coordinates displacements], as from
%                     DaVis - originally 'cdata'
%     dataSize        3 element vector giving size of dataset [X Y Z]
%
% Outputs:
%     dataOut         6 column data corrected for rigid body movement
%     eulerAngles     calculated Euler angles
%     rotCentre       calculated rotation centre
%
% Code originally developed by M. Mostafavi, with additions by M. Jordan.
% Based on Ken Shoemake's Euler angle extraction.
%
% Last edit: November 2014 (M. Jordan)
% (C) 2014, University of Oxford

[r,c,v]=size(PX);
PosX=reshape(PX,[r*c*v,1]);
PosY=reshape(PY,[r*c*v,1]);
PosZ=reshape(PZ,[r*c*v,1]);
uX=reshape(UX,[r*c*v,1]);
uY=reshape(UY,[r*c*v,1]);
uZ=reshape(UZ,[r*c*v,1]);
data3D_col=[PosX,PosY,PosZ,uX,uY,uZ];


disp(' ')
%% 0. Input data check and definitions
%not implemented

%% 1. Clean the dataset
goodidx=~any(isnan(data3D_col),2); % index of non nans.
cdata=data3D_col(goodidx,:); %gets rid of nans


if any(~goodidx)
    disp('WARNING: data contains vectors with partial NaN entries');
end

%% 2. Subtract RBD from displacements
RBD = nanmean(cdata(:,4:6));      %row of 3 RBD coordinates
cdata(:,4:6)=cdata(:,4:6)-repmat(RBD,size(cdata,1),1);
fprintf('RBD /mm: (% 1.4f,% 1.4f,% 1.4f).\n',RBD)


%% 3. Check for rotation correction request

%% 4. Finding the centre of rotation and setting as coordinate origin
% Calculate position of rigid body motion and set as coordinate origin.
%
% X0 coords = index coords of rotn centre
rotCentre = mean(cdata(:,1:3));

%Set rotn centre as coord origin
X0 = [rotCentre 0 0 0];
cdata = bsxfun(@minus,cdata,X0);

%pos0 is the location of points before loading and posd is the location after
%displacement

pos0=cdata(:,1:3);                       % Reference coords
posd=cdata(:,1:3)+cdata(:,4:6);          % Displaced dataset coords

%% 4.1 Calculating rotation matrix, and checking the rank
% Rank should equal 3 to avoid singularity
rank_pos0 = rank(pos0');
rank_posd = rank(posd');

if rank_pos0 ~= 3 || rank_posd ~= 3
    error('ERROR: pos0 or posd rank incorrect. rank_pos0 = %i rank_posd = %i',rank_pos0,rank_posd);
    ERROR
end

R = pos0\posd;  % backslash is MATLAB matrix division - solves for rotation efficiently

%% 4.2 Extracting Euler angles from the rotation matrix
% For more info see http://tinyurl.com/kg3ehzq

if abs(R(3,1))~=1
    theta = -asin(R(3,1));
    %     theta2 = pi - theta;   %This is the redundant 2nd solution;
    %                            %subtitution of theta generates the 3
    %                            %angles. The use of both angles may aid
    %                            %refinement (not implemented)
    psi = atan2(R(3,2)/cos(theta),R(3,3)/cos(theta));
    phi = atan2(R(2,1)/cos(theta),R(1,1)/cos(theta));
else
    phi = 0;
    if R(3,1) == -1
        theta = pi/2;
        psi = phi+atan2(R(1,2),R(1,3));
    else
        theta = -pi/2;
        psi = -phi+atan2(-R(1,2),-R(1,3));
    end
end

euler = [psi theta phi];
disp(['euler = ' num2str(euler,'% 1.3f ')])


%% 4.3.1 Initial estimate of Rotation matrix
%% 4.3.2 Refine estimate of Euler angles and Rot matrix
disp '>>Solver details (refining euler angles):'
disp '***********'


thetaSolver3D = @(t) (R - ...
    [cos(t(2))*cos(t(3)), sin(t(1))*sin(t(2))*cos(t(3))-cos(t(1))*sin(t(3)), cos(t(1))*sin(t(2))*cos(t(3))+sin(t(1))*sin(t(3));...
     cos(t(2))*sin(t(3)), sin(t(1))*sin(t(2))*sin(t(3))+cos(t(1))*cos(t(3)), cos(t(1))*sin(t(2))*sin(t(3))-sin(t(1))*cos(t(3));...
              -sin(t(2)),                               sin(t(1))*cos(t(2)),                                cos(t(1))*cos(t(2))]);
options2 = optimoptions('lsqnonlin','MaxFunEval',1e9,'MaxIter',1e12,'TolFun',1e-10,'Display','final'); %'Algorithm','sqp'
[euler,~] = lsqnonlin(thetaSolver3D,euler,[-2*pi;-2*pi;-2*pi], [2*pi;2*pi;2*pi],options2);
disp '***********'
disp '>>End Solver details'
disp ' '

R_sol=thetaSolver3D(euler);

% disp(['euler = ' num2str(euler,'% 1.3f ')])
disp(['Euler angle /degree: (alpha beta gamma) = (' num2str(radtodeg(euler),'% 1.3f ') ').'])

%{
    disp(['det(R_inital) = ' num2str(det(R))])
    disp('R_initial = ')
    disp(num2str(R))
    disp(' ')
    disp(['det(R_sol) = ' num2str(det(R_sol))])
    disp(['resnorm = ' num2str(resnorm)])
    disp('R_sol = ')
    disp(num2str(R_sol))
%}
%% 4.4 Subtract displacements due to the pure rigid body rotation
posd_theo=(R_sol*pos0')';
rotation_only=pos0-posd_theo;       %= orig coords - rotn coords

%% 4.5 Recreate original and cleaned displacement fields
% Ux,Uy and Uz are displacements. Parameters without a prefix are
% original and rb means rotated back. big_new_data_natural is the final
% matrix similar to data corrected for rotation referenced to input x-y
% frame.

% rUi = disp_theo(:,1:3)  {theoretical displacments}
% Ui = cdata(:,4:6)       {measured displacements}
% rbUi = Ui - rUi         {deformation displacements}

X0 = [rotCentre 0 0 0];
cdata = bsxfun(@plus,cdata,X0);
disp2 = cdata(:,4:6) - rotation_only(:,1:3);
new_data=[cdata(:,1:3) disp2];      %[CleanedCoords DeformDisps] N.B. cdata has been recentred c.f. tdata

%% 5. Recreate original and cleaned displacement fields
% big_new_data_natural=data3D_col;
% 
% j=1;
% for i=1:size(big_new_data_natural)
%     if ~isnan(big_new_data_natural(i,6))
%         big_new_data_natural(i,:)=new_data(j,:);
%         j=j+1;
%     end
% end

%% 7. Define outputs
eulerAngles = euler;
dataOut = new_data;
disp(' ')

PosX(goodidx)=dataOut(:,1);
PosY(goodidx)=dataOut(:,2);
PosZ(goodidx)=dataOut(:,3);
uX(goodidx)=dataOut(:,4);
uY(goodidx)=dataOut(:,5);
uZ(goodidx)=dataOut(:,6);
PX=reshape(PosX,[r,c,v]);
PY=reshape(PosY,[r,c,v]);
PZ=reshape(PosZ,[r,c,v]);
UX=reshape(uX,[r,c,v]);
UY=reshape(uY,[r,c,v]);
UZ=reshape(uZ,[r,c,v]);
end