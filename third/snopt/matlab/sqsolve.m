function [x,fval,exitFlag,output,lambda] = sqsolve(Hx, f, varargin)
% function [x,fval,exitFlag,output,lambda] = sqsolve(Hx, f, varargin)
%
% This function interface is similar to the MATLAB function quadprog.
% However, the Hessian is provided via a user-defined function Hx.
%
% Currently, the only field recognized in the 'option's arguments are
%                options.name,  options.start
% All others are ignored.  Please call the sqset* or sqget* routines to set
% or retrieve options for SQOPT.
%
%
% Calling sequences:
%  x = sqsolve(Hx, f)
%  x = sqsolve(Hx, f, A, b)
%  x = sqsolve(Hx, f, A, b, Aeq, beq)
%  x = sqsolve(Hx, f, A, b, Aeq, beq, lb, ub)
%  x = sqsolve(Hx, f, A, b, Aeq, beq, lb, ub, x0)
%  x = sqsolve(Hx, f, A, b, Aeq, beq, lb, ub, x0, options)
%  x = sqsolve(Hx, f, A, b, Aeq, beq, lb, ub, x0, lambda, states, options)
%
%  [x,fval]                        = sqsolve(Hx, f, ...)
%  [x,fval,exitflag]               = sqsolve(Hx, f, ...)
%  [x,fval,exitflag,output]        = sqsolve(Hx, f, ...)
%  [x,fval,exitflag,output,lambda] = sqsolve(Hx, f, ...)
%
%
% Solve the given quadratic problem:
%       minimize        q(x) = half*x'*H*x + f'*x
%     subject to   lb <=  x  <= ub
%                       A*x  <= b
%                     Aeq*x   = beq
%
%   INPUT:
%     Hx       is a user-defined function that returns the product of a
%              vector and the Hessian matrix of the objective
%
%     f        is the linear term of the objective
%
%     A, b     contain the linear inequality constraints A*x <= b
%
%     Aeq, beq(optional) contain the lineaer equality constraints Aeq*x <= beq
%
%     lb, ub  (optional) are the lower and upper bounds of x
%
%     x0       is the initial point x
%
%     options  is a struct.
%              options.name   is the problem name
%              options.start  'Cold', 'Warm'
%
%
%   OUTPUT:
%     x        is the final point
%
%     fval     is the final objective value
%
%     exitFlag is the exit flag returned by SQOPT
%
%     output   is a structure containing run information --
%              output.iterations is the total number of iterations
%              output.funcCount   is the total number of function evaluations
%
%     lambda   is a structure containing the multipliers
%              lambda.x          are for the variables
%              lambda.linear     are for the linear constraints
%
%     states   is a structure containing the states
%              states.x          are for the variables
%              states.linear     are for the linear constraints
%
solveOpt = 1;

probName = '';
start    = 'Cold';

userHx = checkFun(Hx,'SQOPT','Hx');

if nargin == 2,
  % sqsolve(Hx, f)
  A   = [];  b   = [];
  Aeq = [];  beq = [];
  lb  = [];  ub  = [];
  x0  = [];

  xstate = []; xmul = [];
  astate = []; amul = [];

elseif nargin == 4,
  % sqsolve(Hx, f, A, b)
  A = varargin{1};
  b = varargin{2};
  Aeq = [];  beq = [];
  lb  = [];  ub  = [];
  x0  = [];

  xstate = []; xmul = [];
  astate = []; amul = [];


elseif nargin == 6,
  % sqsolve(Hx, f, A, b, Aeq, beq)
  A   = varargin{1};
  b   = varargin{2};
  Aeq = varargin{3};
  beq = varargin{4};
  lb  = [];  ub  = [];
  x0  = [];

  xstate = []; xmul = [];
  astate = []; amul = [];

elseif nargin == 8,
  % sqsolve(Hx, f, A, b, Aeq, beq, lb, ub)
  A   = varargin{1};
  b   = varargin{2};
  Aeq = varargin{3};
  beq = varargin{4};
  lb  = varargin{5};
  ub  = varargin{6};
  x0  = [];

  xstate = []; xmul = [];
  astate = []; amul = [];

elseif nargin == 9,
  % sqsolve(Hx, f, A, b, Aeq, beq, lb, ub, x0)
  A   = varargin{1};
  b   = varargin{2};
  Aeq = varargin{3};
  beq = varargin{4};
  lb  = varargin{5};
  ub  = varargin{6};
  x0  = varargin{7};

  xstate = []; xmul = [];
  astate = []; amul = [];

elseif nargin == 10 || nargin == 12,
  % sqsolve(Hx, f, A, b, Aeq, beq, lb, ub, x0, options)
  % sqsolve(Hx, f, A, b, Aeq, beq, lb, ub, x0, lambda, states, options)
  A   = varargin{1};
  b   = varargin{2};
  Aeq = varargin{3};
  beq = varargin{4};
  lb  = varargin{5};
  ub  = varargin{6};
  x0  = varargin{7};

  xstate = []; xmul = [];
  astate = []; amul = [];

  if nargin == 12,
    lambda = varargin{8};
    states = varargin{9};

    xstate = states.x;
    xmul   = lambda.x;
    astate = states.linear;
    amul   = lambda.linear;
  end

  % Deal with options.
  optionsLoc = 10;
  if isstruct(varargin{optionsLoc}),
    options = varargin{optionsLoc};
    % Name
    if isfield(options,'name'),
      probName = options.name;
    end

    % Start
    if isfield(options,'start'),
      if strcmp(lower(options.start),'warm'),
	istart = 2;
      elseif strcmp(lower(options.start),'hot'),
	istart = 3;
      end
    end

  else
    error('SQOPT:InputArgs','Options struct error');
  end

else
  error('SQOPT:InputArgs','Wrong number of input arguments for sqsolve');
end

ineq = size(A,1);
AA   = [                 A; Aeq ];
al   = [ -inf*ones(ineq,1); beq ];
au   = [                 b; beq ];

[x,fval,exitFlag,itn,y,state] = sqoptmex(solveOpt, start, probName, ...
					 userHx, f, x0, lb, ub, xstate, xmul, ...
					 AA,  al, au, astate, amul);

% Set output
output.iterations = itn;

m    = size(AA,1);
n    = size(x0,1);
zero = zeros(n,1);

states.x      = state(1:n);
lambda.x      = y(1:n);
if m > 0,
  states.linear = state(n+1:n+m);
  lambda.linear = y(n+1:n+m);
end
