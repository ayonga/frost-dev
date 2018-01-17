% When Matlab starts up, it looks for a file called startup.m in the
% directory (folder) in which it is being started.  If such a file is
% found, then it is automatically executed as part of Matlab's start-up
% procedure.  The line at the end of this file tells Matlab to add the
% directory '/home/users/roy/booksoft/spatial_v2', and all of its
% subdirectories, to Matlab's command search path.  An action like this is
% necessary if Matlab is to find all of the functions in spatial_v2.

% WHAT YOU MUST DO:
% (1) Replace the string '/home/users/roy/booksoft/spatial_v2' with the
%     full path name of your directory spatial_v2 (keeping the two
%     single-quotes that delimit the string).  For example, on a Windows
%     PC, if you downloaded spatial_v2.zip to the folder C:\user\john and
%     unzipped it there, then the replacement string will be
%     'C:\user\john\spatial_v2'.
% (2) Copy this file to each directory in which you want Matlab to have
%     access to spatial_v2 when it starts.  If there is already a file
%     startup.m in that directory, then simply add the (edited) line
%     below to that file.

addpath( genpath( '/home/users/roy/booksoft/spatial_v2' ) );
