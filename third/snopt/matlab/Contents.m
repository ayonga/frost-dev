%
% snopt m-files
% -------------
%
% snsolve.m
%     is a simple mex interface to the Fortran routine snOptA.  This
%     routine finds the minimum of a smooth nonlinear function subject to
%     linear and nonlinear constraints.
%
%     snopt.m may be called in one of four ways, depending on the number
%     of arguments in the calling sequence.  In general, the robustness
%     increases with the number of arguments (and complexity).
%
%     The user need not provide the derivatives of the problem functions,
%     although user-provided derivatives increase the speed and
%     reliability of snopt.  The problem derivatives may be provided
%     in either dense or sparse format.
%
%     Examples that provide all problem information and all derivatives:
%       hs13   hsmain   snoptmain2   sntoy   t1diet
%
%     Examples that provide all problem information and only some
%     derivatives:
%       snoptmain3
%
%     Examples that provide problem information and no derivatives:
%       snoptmain   sntoy2
%
% snsolve.m
%     is also a mex interface to snOptA.  Its calling sequence is based
%     on Matlab's "fmincon" function.
%
% snend.m
%     must be called after calling snsolve.m to deallocate memory and reset
%     workspace and settings.
%
% snscreen.m
%     starts and stops a copy of the summary output being printed to the
%     Matlab terminal display.
%
%     To start output to the screen, type:
%       >> snscreen on;
%     To stop  output to the screen, type:
%       >> snscreen off;
%     Screen output may be simultaneously appended to a file (see "snsummary").
%
%
% snsummary.m
%     saves summary information to a file.
%       >> snsummary ('probName.sum');   % Starts printing on probName.sum
%       >> snsummary   off;              % Closes the summary file
%
%     Note: data is appended to the summary file.
%     It may be necessary to close the summary file to purge the summary buffer.
%
%
% snprint.m
%     saves detailed information about the progress of snopt to a file.
%       >> snprint   ('probName.out');   % Starts printing on probName.out
%       >> snprint    off;               % Closes the print file
%
%     It may be necessary to close the print file to purge the print buffer.
%
%
% snspec.m
%     reads an options file for the snopt optimization routine.
%       >> t1diet.spc = which('t1diet.spc');
%       >> snspec ( t1diet.spc );
%
%
% snset, snseti, snsetr
%     set advanced options for the snopt optimization routine.
%
%
% snget, sngeti, sngetr
%     retrieve current values of snopt optional parameters.
%     (they have the opposite effect of snset, snseti, and snsetr)
%
%
% snJac
%     finds the coordinate structure for sparse derivatives.
%
%
% Philip Gill
% Joshua Griffin
% Elizabeth Wong
%
% Updated:                               19 Oct  2004
%                                         4 May  2006
%                                        18 Jun  2007
%                                        28 Sep  2013
