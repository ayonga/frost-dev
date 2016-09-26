function result = strstartswith(s, pat)
%STRSTARTSWITH Determines whether a string starts with a specified pattern
%
%   result = strstartswith(s, pat);
%       returns whether the string s starts with a sub-string pat.
%

%   History
%   -------
%       - Created by Dahua Lin, on Oct 9, 2008
%       - Extended by Eric Cousineau, on Dec 2012

%% main

nPat = length(pat);
if ~iscell(pat)
    result = strncmp(s, pat, nPat);
else
    result = false(1, nPat);
    for i = 1:nPat
        result(i) = strncmp(s, pat{i}, length(pat{i}));
    end
end
