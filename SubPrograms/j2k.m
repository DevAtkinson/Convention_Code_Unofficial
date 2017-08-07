function [ KI,KII,KIII] = j2k(stress_state,JI,JII,JIII,E,v)
%J2K Summary of this function goes here
%   Detailed explanation goes here

%% Simple processing to fill missing material data
if strcmp(stress_state,'plane_stress')
    Estar=E;
elseif strcmp(stress_state,'plane_strain')
    Estar=E/(1-v^2);
end


G = E/(2*(1 + v)); %shear modolus, should this use Estar as well?

KI=abs(sqrt(JI*Estar));
KII=abs(sqrt(JII*Estar));
KIII=abs(sqrt(JIII*2*G));
% KIII=abs(sqrt(JIII/(1+v)*E));
end