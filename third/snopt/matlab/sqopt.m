function [x,obj,INFO,output,lambda,states] = sqopt(Hx, c, x0, xl, xu, A, al, au, varargin)
% function [x,obj,INFO,output,lambda,states] = sqopt(Hx, c, x0, xl, xu, A, al, au, varargin)
%
% This function solves the quadratic optimization problem:
%   minimize:
%              c'x + x'*H*x
%   subject to:
%            xl <=  x <= xu
%            al <= Ax <= au
% where:
%  x        is the column vector of initial values of the unknowns
%  xl, xu   are the lower and upper bounds of the variables
%  c        is the linear term of the objective
%  H        is the Hessian matrix of the objective
%  A        is the linear constraint matrix
%  al, au   are the lower and upper bounds of the linear constraints
%
% Calling sequences:
%  [] = sqopt(Hx, c, x0, xl, xu, A, al, au)
%  [] = sqopt(Hx, c, x0, xl, xu, A, al, au, options)
%
%  [] = sqopt(Hx, c, x0, xl, xu, A, al, au, states, lambda)
%  [] = sqopt(Hx, c, x0, xl, xu, A, al, au, states, lambda, options)
%
%  [x,obj,INFO,output,lambda,states] = sqopt(...)
%
%
% INPUT:
%  x0                is the initial guess for x
%
%  Hx                is a Matlab function that computes H*x for a given x.
%                    Hx can be a Matlab function handle or a string
%
%  c                 is the linear term of the quadratic objective
%
%  xl, xu            are the upper and lower bounds on x
%
%  A                 is the linear constraint matrix. A can be a dense
%                    matrix or a sparse matrix.
%
%  al, au            are the upper and lower bounds on the linear constraints A*x
%
% OUTPUT:
%     x        is the final point
%
%     obj      is the final objective value
%
%     exitFlag is the exit flag returned by DQOPT
%
%     output   is a structure containing run information --
%              output.iterations is the total number of iterations
%              output.funcCount   is the total number of function evaluations
%
%     lambda   is a structure containing the multipliers
%              lambda.x          are for the variables
%              lambda.linear     are for the linear constraints
%
%     states   is a structure
%              states.x          are for the variables
%              states.linear     are for the linear constraints
%

solveOpt = 1;

probName = '';
start    = 'Cold';

% Deal with options.
optionsLoc = 0;
if nargin == 9 || nargin == 11,
  optionsLoc = nargin - 8;
  if isstruct(varargin{optionsLoc}),
    options = varargin{optionsLoc};
    % Name
    if isfield(options,'name'),
      probName = options.name;
    end

    % Start
    if isfield(options,'start'),
      start = options.start;
    end
  else
    optionsLoc = 0;
  end
end

userHx = checkFun(Hx,'SQOPT','Hx');

if nargin == 8 || nargin == 9,
  % sqopt(Hx, c, x0, xl, xu, A, al, au)
  % sqopt(Hx, c, x0, xl, xu, A, al, au, options)

  xstate = []; xmul = [];
  astate = []; amul = [];

elseif nargin == 10 || nargin == 11,
  % sqopt(Hx, c, x0, xl, xu, A, al, au, states, lambda)
  % sqopt(Hx, c, x0, xl, xu, A, al, au, states, lambda, options)

  states = varargin{1};
  lambda = varargin{2};

  xstate = []; xmul   = [];
  astate = []; amul   = [];

  if isfield(states,'x'),
    xstate = states.x;
  end

  if isfield(lambda,'x'),
    xmul = lambda.x;
  end

  if isfield(states,'linear'),
    astate = states.linear;
  end

  if isfield(lambda,'linear'),
    amul = lambda.linear;
  end

else
  error('SQOPT:InputArgs','Wrong number of arguments in SQOPT');
end

if isempty(A),
  % Setup fake constraint matrix and bounds
  warning('SQOPT:InputArgs','No linear constraints detected; dummy constraint created');

  m = 1;
  n = size(x0,1);

  neA     = 1;
  indA(1) = 1;
  valA(1) = 1.0;

  locA(1) = 1;
  locA(2:n+1) = 2;
  locA    = locA';
  al = [-inf]; au = [inf];

else
  [m,n]                = size(A);
  [neA,indA,locA,valA] = crd2spr(A);
end

x0  = colvec(x0,'x0',1,n);
xl  = colvec(xl,'xl',1,n);
xu  = colvec(xu,'xu',1,n);
al  = colvec(al,'al',1,m);
au  = colvec(au,'au',1,m);
c   = colvec(c,'c',1,0);

[x,obj,INFO,itn,y,state] = sqoptmex(solveOpt, start, probName, ...
				    m, n, userHx, c, ...
				    x0, xl, xu, xstate, xmul, ...
				    neA, indA, locA, valA, al, au, astate, amul);

% Set output
output.iterations = itn;
output.info       = INFO;

zero     = zeros(n,1);
states.x = state(1:n);
lambda.x = y(1:n);

if m > 0,
  states.linear = state(n+1:n+m);
  lambda.linear = y(n+1:n+m);
end
