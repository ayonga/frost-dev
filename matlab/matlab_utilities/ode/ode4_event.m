%> @brief Perform fixed-step fourth-order Runge-Kutta event-based integration
%> @author Unknown (url: http://code.google.com/p/jmdalyphdresearch/)
%> @author Eric Cousineau <eacousineau@gmail.com>, member of Dr. Aaron
%> Ames's AMBER Lab
%> @param odefun Function handle of the form:
%>    [dy, event, calc] = odefun(t, y, ts_prev, Y_prev, calcs_prev, varargin)
%> where ts_prev and Y_prev are the solution up to that point, calcs_prev is 
%> a cell array of stored values of calc, and event is a
%> boolean value where, if true, integration is stopped, and calc is
%> auxiliary information that is gathered when intergrating.
%> @note In this case, t == ts_prev(end), y == Y_prev(:, end)
%> @param tspan Vector of strictly monotonically increasing time values
%> @param y0 Initial condition
%> @param varargin Extra arguments to pass to odefun
function [tspan, Y, calcs, flags] = ode4_event(odefun, tspan, y0, varargin)

%> @todo Generalize for integrator type: RK4, RK5, and Taylor

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
F = zeros(neq,4);
calcs = cell(1,N);

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
    [F(:,1), event, calc] = feval(odefun,ti,yi,tspan_prev,Y_prev,calcs_prev,varargin{:});
    if event
        % Exit integration, truncating results
        %> @todo Determine if last computation should be included
        Y = Y(:, 1:i-1);
        tspan = tspan(1:i-1);
        calcs = calcs(1:i-1);
        flags = 1;
        break;
    end
    F(:,2) = feval(odefun,ti+0.5*hi,yi+0.5*hi*F(:,1),tspan_prev,Y_prev,calcs_prev,varargin{:});
    F(:,3) = feval(odefun,ti+0.5*hi,yi+0.5*hi*F(:,2),tspan_prev,Y_prev,calcs_prev,varargin{:});
    F(:,4) = feval(odefun,tspan(i),yi+hi*F(:,3),tspan_prev,Y_prev,calcs_prev,varargin{:});
    
    Y(:,i) = yi + (hi/6)*(F(:,1) + 2*F(:,2) + 2*F(:,3) + F(:,4));
    % This computation occurs for last value
    calcs{i-1} = calc;
end

% Include last computation
% @note This is not a repeat expression
[~, ~, calcs{end}] = feval(odefun,tspan(end), Y(:, end), tspan, Y(:, 1:end-1), calcs(1:end-1), varargin{:});
