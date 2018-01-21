%Test Script.

format compact;
setpath;  % defines the path

sqscreen on

fprintf('\n============================================================= ');
fprintf('\nhs76: sqopt solves quadratic problem hs76 ... ');
[x,Obj,info] = hs76;

sqscreen off
