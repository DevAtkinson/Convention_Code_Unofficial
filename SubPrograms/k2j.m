function [ JI,JII,JIII,Estar] = k2j(stress_state,KI,KII,KIII,E,v)
%J2K Simply converts stress intensity factors K into J-integral values J


%% Simple processing to fill missing material data
if strcmp(stress_state,'plane_stress')
        Estar=E;
    elseif strcmp(stress_state,'plane_strain')
        Estar=E/(1-v^2);
end

G = E/(2*(1 + v)); %shear modolus, should this use Estar as well?

JI=KI.^2/Estar;
JII=KII.^2/Estar;
JIII =KIII.^2/(2*G);
% JIII=KIII.^2*((1+v)*E);
end

