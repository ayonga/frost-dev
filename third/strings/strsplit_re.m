function terms = strsplit_re(s, delimiter)
%STRSPLIT_RE Splits a string into multiple terms with regex delimiter
%
%   terms = strsplit_re(s, delimiter);
%       splits the string s into multiple terms with delimiter specified
%       by a regular expression.
%
%       The extracted terms are returned in form of a cell array of
%       strings.
%
%   Remarks
%   -------
%       - If there are two consecutive non-whitespace delimiters, it is
%         regarded that there is an empty-string term between them. 
%
%   Examples
%   --------
%       % split a string by whitespaces
%       ts = strsplit_re('I am using MATLAB', '\s+');
%       ts <- {'I', 'am', 'using', 'MATLAB'}
%
%       % extract terms delimited by commas 
%       ts1 = strsplit_re('Apple, Orange , Banana', ',');
%       ts1 <- {'Apple', ' Orange ', ' Banana'}
%
%       ts2 = strsplit_re('Apple, Orange , Banana', '\s*,\s*');
%       ts2 <- {'Apple', 'Orange', 'Banana'}
%
%       % consecutive delimiters results in empty terms
%       ts = strsplit_re(',Apple,,Orange,Banana', ',');
%       ts <- {'', 'Apple', '', 'Orange', 'Banana'}
%

%   History
%   -------
%       - Created by Dahua Lin, on Oct 9, 2008
%

%% parse and verify input arguments

assert(ischar(s) && ndims(s) == 2 && size(s,1) <= 1, ...
    'strsplit_re:invalidarg', ...
    'The first input argument should be a char string.');

d = delimiter;
assert(ischar(d) && ndims(d) == 2 && size(d,1) == 1 && ~isempty(d), ...
    'strsplit_re:invalidarg', ...
    'The delimiter should be a non-empty char string.');

%% main

[sp, ep] = regexp(s, d, 'start', 'end');

if ~isempty(sp)
    nt = numel(sp) + 1;
    terms = cell(1, nt);
    p = 1;
    for i = 1 : nt-1
        if p < sp(i)
            terms{i} = s(p:sp(i)-1);
        else
            terms{i} = '';
        end     
        p = ep(i) + 1;
    end
    if p <= length(s)
        terms{nt} = s(p:end);
    else
        terms{nt} = '';
    end
else
    terms = {s};
end

