% Analysis of Drift in Conserved Quantities in Simulink Example 4
% ---------------------------------------------------------------
%
% It is assumed that Example 4 has already been run, and that there is
% therefore a variable called tout, and another called xout, containing the
% results of a simulation run.  This script calculates and plots drift in
% kinetic energy, position and velocity of centre of mass, and spatial
% momentum.  Potential energy is always exactly zero because gravity is
% zero.

N = length(tout);

for i = 1:N
  [q,qd] = fbkin( xout(:,1,i) );
  ret = EnerMo( singlebody, q, qd );
  KE(i) = ret.KE;
  cm(:,i) = ret.cm;
  vcm(:,i) = ret.vcm;
  h(:,i) = ret.htot;
end

KEdrift = KE - KE(1);
cmdrift = cm - cm(:,1) * ones(1,N);
vcmdrift = vcm - vcm(:,1) * ones(1,N);
hdrift = h - h(:,1) * ones(1,N);

plot( tout, KEdrift );
title( 'Drift in Kinetic Energy' );

figure;
plot( tout, [cmdrift; vcmdrift] );
title( 'Drift in Centre of Mass Location and Velocity' );
legend('x', 'y', 'z', 'x vel', 'y vel', 'z vel', 'Location', 'NorthWest');

figure;
plot( tout, hdrift );
title( 'Drift in Spatial Momentum' );
legend('ang x', 'ang y', 'ang z', 'lin x', 'lin y', 'lin z', ...
       'Location', 'NorthWest');
