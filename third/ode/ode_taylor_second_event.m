%> @brief Explicitly perform second order Taylor series integration on a
%> first-order transformed second order system.
%> @param odefun Function of the form
%>    [dy, event, calc] = odefun(t, y, ts_prev, Y_prev, calcs_prev, varargin)
function [tspan, Y, calcs, flags] = ode_taylor_second_event(odefun, tspan, y0, varargin)

if ~isnumeric(tspan)
  error('TSPAN should be a vector of integration steps.');
end

if ~isnumeric(y0)
  error('Y0 should be a vector of initial conditions.');
end

h = diff(tspan);
if any(sign(h(1))*h <= 0)
  error('Entries of TSPAN are not in order.') 
end  

[f0, event, calc0] = feval(odefun,tspan(1),y0,[],[],[],varargin{:});

y0 = y0(:);   % Make a column vector.
if ~isequal(size(y0),size(f0))
  error('Inconsistent sizes of Y0 and f(t0,y0).');
end  

neq = length(y0);
N = length(tspan);
Y = zeros(neq,N);
calcs = cell(1,N);

ndof = neq / 2;
% Position Inidices
ix = 1:ndof;
% Velocity Indices
idx = ndof + ix;

Y(:,1) = y0;
calcs{1} = calc0;

% Special case: Handle trigger at the start
if event
    Y = y0;
    tspan = tspan(1);
    calcs = calc0;
    flags = 1;
    return;
end

flags = 0;

for i = 2:N
  ti = tspan(i-1);
  hi = h(i-1);
  yi = Y(:,i-1);

  Y_prev = Y(:, 1:i-2);
  tspan_prev = tspan(1:i-2);
  calcs_prev = calcs(1:i-2);

  [f, event, calc] = feval(odefun,ti,yi,tspan_prev,Y_prev,calcs_prev,varargin{:});
  if event
    % Exit integration, truncating results
    %> @todo Determine if last computation should be included
    Y = Y(:, 1:i-1);
    tspan = tspan(1:i-1);
    calcs = calcs(1:i-1);
    flags = 1;
    break;
  end

  % Position
  Y(ix,i) = yi(ix) + hi * f(ix) + hi * hi / 2 * f(idx);
  % Velocity
  Y(idx, i) = yi(idx) + hi * f(idx);
  % This computation occurs for last value
  calcs{i-1} = calc;
end

% Include last computation
% @note This is not a repeat expression
[~, ~, calcs{end}] = feval(odefun,tspan(end), Y(:, end), tspan, Y(:, 1:end-1), calcs(1:end-1), varargin{:});
