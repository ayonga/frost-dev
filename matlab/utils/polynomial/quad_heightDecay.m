%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% File Name: quad_heightDecay.m
%%%%% Create   : Aaron Ames
%%%%% Modified : Ayonga Hereid
%%%%% Copyright: AMBER Lab, Texasl A&M University
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h = quad_heightDecay(t,hmax,Ttau,ha)

    a = -2*hmax/(Ttau^2);
    b = 2*hmax/Ttau;	
    % 	h = a*t.^2 + b*t + (ha - a*ank_minus^2 - b*ank_minus);
    %     h = (a*t.^2 + b*t) + ha;
    h = (a.*t.^2 + b.*t).*3.*exp(-1.*t) + ha;

