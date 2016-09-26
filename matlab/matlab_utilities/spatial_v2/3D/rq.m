function  out = rq( in )

% rq  unit quaternion <--> 3x3 coordinate rotation matrix
% E=rq(q) and q=rq(E)  convert between a unit quaternion q, representing
% the orientation of a coordinate frame B relative to frame A, and the 3x3
% coordinate rotation matrix E that transforms from A to B coordinates.
% For example, if B is rotated relative to A about their common X axis by
% an angle h, then q=[cos(h/2);sin(h/2);0;0] and rq(q) produces the same
% matrix as rx(h).  If the argument is a 3x3 matrix then it is assumed to
% be E, otherwise it is assumed to be q.  rq(E) expects E to be accurately
% orthonormal, and returns a quaternion in a 4x1 matrix; but rq(q) accepts
% any nonzero quaternion, contained in either a row or a column vector, and
% normalizes it before use.  As both q and -q represent the same rotation,
% rq(E) returns the value that satisfies q(1)>0.  If q(1)==0 then it picks
% the value such that the largest-magnitude element is positive.  In the
% event of a tie, the smaller index wins.

if all(size(in)==[3 3])
  out = Etoq( in );
else
  out = qtoE( in );
end


function  E = qtoE( q )

q = q / norm(q);

q0s = q(1)*q(1);
q1s = q(2)*q(2);
q2s = q(3)*q(3);
q3s = q(4)*q(4);
q01 = q(1)*q(2);
q02 = q(1)*q(3);
q03 = q(1)*q(4);
q12 = q(2)*q(3);
q13 = q(4)*q(2);
q23 = q(3)*q(4);

E = 2 * [ q0s+q1s-0.5, q12 + q03,   q13 - q02;
	  q12 - q03,   q0s+q2s-0.5, q23 + q01;
	  q13 + q02,   q23 - q01,   q0s+q3s-0.5 ];


function  q = Etoq( E )

% for sufficiently large q0, this function formulates 2*q0 times the
% correct return value; otherwise, it formulates 4*|q1| or 4*|q2| or 4*|q3|
% times the correct value.  The final normalization step yields the correct
% return value.

tr = trace(E);				% trace is 4*q0^2-1
v = -skew(E);				% v is 2*q0 * [q1;q2;q3]

if tr > 0
  q = [ (tr+1)/2; v ];
else
  E = E - (tr-1)/2 * eye(3);
  E = E + E';
  if E(1,1) >= E(2,2) && E(1,1) >= E(3,3)
    q = [ 2*v(1); E(:,1) ];
  elseif E(2,2) >= E(3,3)
    q = [ 2*v(2); E(:,2) ];
  else
    q = [ 2*v(3); E(:,3) ];
  end
  if q(1) < 0
    q = -q;
  end
end

q = q / norm(q);
