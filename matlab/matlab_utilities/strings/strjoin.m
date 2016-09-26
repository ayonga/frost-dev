function s = strjoin(terms, delimiter)
%STRJOIN Creates a string by joining multiple terms
%
%   s = strjoin({t1, t2, ..., tn});
%       creates a new string by joining n terms in a cell array, which
%       are separated by white spaces.
%
%   s = strjoin({t1, t2, ..., tn}, delimiter);
%       creates a new string by joining n terms in a cell array with
%       specified delimiter.
%
%   Examples
%   --------
%       % Join words with white spaces
%       s = strjoin({'I', 'am', 'using', 'MATLAB'});
%       s <- 'I am using MATLAB'
%
%       % Join terms with a user-specified delimiter
%       s = strjoin({'1', '2', '3', '4'}, ' + ');
%       s <- '1 + 2 + 3 + 4'
%
%       % Join a set of single term results in that term itself
%       s = strjoin({'abc'});
%       s <- 'abc'
%
%       % Join an empty set results in an empty string
%       s = strjoin({});
%       s <- ''
%

%   History
%   -------
%       - Created by Dahua Lin, on Oct 9, 2008
%

%% parse and verify input arguments

assert(iscellstr(terms), 'strjoin:invalidarg', ...
    'The first argument should be a cell array of strings.');

if nargin < 2
    d = ' ';
else
    d = delimiter;
    assert(ischar(d) && ndims(d) == 2 && size(d,1) <= 1, ...
        'strjoin:invalidarg', ...
        'The delimiter should be a char string.');
end

%% main

n = numel(terms);
if n == 0
    s = '';
elseif n == 1
    s = terms{1};
else
    ss = cell(1, 2*n-1);
    ss(1:2:end) = terms;
    [ss{2:2:end}] = deal(d);
    s = [ss{:}];
end




        