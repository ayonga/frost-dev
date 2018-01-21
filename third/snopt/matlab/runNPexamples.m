%Test Script.

format compact;
setpath;  % defines the path

snscreen on

fprintf('\n============================================================= ');
fprintf('\nsntoy: Solving diet LP problem using SNOPT ... ');
[x,xmul,F,Fmul,info] = t1diet;

fprintf('\n============================================================= ');
fprintf('\nsntoy: Solving toy problem using SNOPT ... ');
snset ('Defaults');    % Advisable between runs of different problems
[x,xmul,F,Fmul,info] = sntoy;

fprintf('\n============================================================= ');
fprintf('\ntoymin: Solving toy problem using fmincon-style SNOPT ... ');
snset ('Defaults');    % Advisable between runs of different problems
[x,F,info] = toymin;

fprintf('\n============================================================= ');
fprintf('\nhsmain: snopt solves hs47 ... ');
snset ('Defaults');
[x,xmul,F,Fmul,info] = hsmain;

fprintf('\n============================================================= ');
fprintf('\nsntoy2: snopt solves toy problem ... ');
snset ('Defaults');
[x,F,info] = sntoy2;

fprintf('\n============================================================= ');
fprintf('\nsnoptmain: snopt solves hexagon with no derivatives ... ');
snset ('Defaults');
[x,F,info] = snoptmain;

fprintf('\n============================================================= ');
fprintf('\nsnoptmain2: snopt solves hexagon with dense Jacobian ... ');
snset ('Defaults');
[x,F,info] = snoptmain2;

fprintf('\n============================================================= ');
fprintf('\nsnoptmain3: snopt solves hexagon with some derivatives ... ');
snset ('Defaults');
[x,F,info] = snoptmain3;

fprintf('\n============================================================= ');
fprintf('\nhs116: snopt solves hs116 ... ');
snset ('Defaults');
[x,F,info] = hs116;

fprintf('\n============================================================= ');
fprintf('\nhs116: snopt solves hs116 ... ');
snset ('Defaults');
[x,F,info] = hs116;

fprintf('\n============================================================= ');
fprintf('\nspring: snopt solves springA ... ');
snset ('Defaults');
[x,xmul,F,Fmul,info] = springa;

snscreen off
