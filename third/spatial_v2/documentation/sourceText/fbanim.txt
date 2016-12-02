function  Q = fbanim( X, Qr )

% fbanim  Floating Base Inverse Kinematics for Animation
% Q=fbanim(X) and Q=fbanim(X,Qr) calculate matrices of joint position data
% for use in showmotion animations.  Q=fbanim(X) calculates a 6xN matrix Q
% from a 13x1xN or 13xN or 7x1xN or 7xN matrix X, such that each column of
% X contains at least the first 7 elements of a 13-element singularity-free
% state vector used by FDfb and IDfb, and the corresponding column of Q
% contains the position variables of the three prismatic and three revolute
% joints that form the floating base.  Each column of Q is calculated using
% fbkin; but fbanim then adjusts the three revolute joint variables to
% remove the pi and 2*pi jumps that occur when the angles wrap around or
% pass through a kinematic singularity.  As a result, some or all of the
% revolute joint angles may grow without limit.  This is essential for a
% smooth animation.  Q=fbanim(X,Qr) performs the same calculation as just
% described, but then appends Qr to Q.  Qr must be an MxN or Mx1xN matrix
% of joint position data for the real joints in a floating-base mechanism,
% and the resulting (6+M)xN matrix Q contains the complete set of joint
% data required by showmotion.  Note: the algorithm used to remove the
% jumps makes continuity assumptions (specifically, less than pi/2 changes
% from one column to the next, except when passing through a singularity)
% that are not guaranteed to be true.  Therefore, visible glitches in an
% animation are still possible.

if length(size(X)) == 3			% collapse 3D -> 2D array
  tmp(:,:) = X(:,1,:);
  X = tmp;
end

% apply kinematic transform using fbkin

for i = 1 : size(X,2)
  Q(:,i) = fbkin( X(1:7,i) );
end

% This code removes wrap-arounds and step-changes on passing through a
% singularity.  Whenever q6 or q4 wrap, they jump by 2*pi.  However, when
% q5 hits pi/2 (or -pi/2), q4 and q6 both jump by pi, and q5 turns around.
% To undo this, the code looks to see whether n is an even or odd number,
% and replaces q5 with pi-q5 whenever n is odd.  q4 is calculated via the
% sum or difference of q4 and q6 on the grounds that the sum well defined
% at the singularity at q5=pi/2 and the difference is well defined at
% q5=-pi/2.

for i = 2 : size(X,2)
  n = round( (Q(6,i-1) - Q(6,i)) / pi );
  q6 = Q(6,i) + n*pi;
  if Q(5,i) >= 0
    q46 = Q(4,i) + Q(6,i);
    q46 = q46 + 2*pi * round( (Q(4,i-1)+Q(6,i-1) - q46) / (2*pi) );
    Q(4,i) = q46 - q6;
  else
    q46 = Q(4,i) - Q(6,i);
    q46 = q46 + 2*pi * round( (Q(4,i-1)-Q(6,i-1) - q46) / (2*pi) );
    Q(4,i) = q46 + q6;
  end
  Q(6,i) = q6;
  if mod(n,2) == 0
    q5 = Q(5,i);
  else
    q5 = pi - Q(5,i);
  end
  Q(5,i) = q5 + 2*pi * round( (Q(5,i-1) - q5) / (2*pi) );
end

% add the rest of the joint data, if argument Qr has been supplied

if nargin == 2
  if length(size(Qr)) == 3		% collapse 3D -> 2D array
    tmp = zeros(size(Qr,1),size(Qr,3));
    tmp(:,:) = Qr(:,1,:);
    Qr = tmp;
  end
  Q = [ Q; Qr ];
end
