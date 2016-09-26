function r = strgsub(s, re, replacement)
%STRGSUB Replaces all substrings matching a specified pattern
%
%   r = strgsub(s, re, newstring);
%       replaces all substrings in s that match the regular expression
%       re by the newstring.
%
%   r = strgsub(s, re, translatef);
%       translates all substrings in s that match the regular expression
%       re using the function translatef, which should be a function
%       handle.
%
%   Examples
%   --------
%       % replaces all occurrences of a particular string by a new one
%       r = strgsub('It is in year 1998 and year 2004', 'year', 'yr');
%       r <- 'It is in yr 1998 and yr 2004'
%
%       % replaces all substrings matching a pattern by a fixed string
%       r = strgsub('It is in year 1998 and year 2004', '\d+', '####');
%       r <- 'It is in year #### and year ####'
%
%       % squeezes consecutive spaces to one space
%       r = strgsub('A  b    c      d', '\s+', ' ');
%       r <- 'A b c d'
%
%       % Capitalize each word
%       r = strgsub('you and me', '\w+', @(x) [upper(x(1)), x(2:end)]);
%       r <- 'You And Me'
%
%       % increment each number occurred in a string by one
%       r = strgsub('10:20 34:562', '\d+', @(x) int2str(str2double(x)+1));
%       r <- '11:21 35:563'
%       

%   History
%   -------
%       - Created by Dahua Lin, on Oct 9, 2008
%

%% parse and verify input arguments

assert(ischar(s) && ndims(s) == 2 && size(s,1) <= 1, ...
    'strgsub:invalidarg', ...
    'The first input argument should be a char string.');

assert(ischar(re) && ndims(re) == 2 && size(re,1) == 1 && ~isempty(re), ...
    'strgsub:invalidarg', ...
    'The regular expression should be a non-empty char string.');

if ischar(replacement)
    s2 = replacement;
    assert(ischar(s2) && ndims(s2) == 2 && size(s2,1) <= 1, ...
        'strgsub:invalidarg', ...
        'The size of the string of replacement is illegal.');    
    direct_replace = true;
    
elseif isa(replacement, 'function_handle')
    tf = replacement;
    direct_replace = false;
    
else
    error('strgsub:invalidarg', ...
        'replacement should be either a string or a function handle.');
end

%% main

if direct_replace
    [sp, ep] = regexp(s, re, 'start', 'end');    
    
    if ~isempty(sp)        
        r = do_replace(s, sp, ep, s2);
    else
        r = s;
    end
else
    [sp, ep, ms] = regexp(s, re, 'start', 'end', 'match');
    
    if ~isempty(sp)
        s2 = cell(size(ms));
        for i = 1 : numel(s2)
            s2{i} = tf(ms{i});
        end
        r = do_replace(s, sp, ep, s2);
    else
        r = s;
    end    
end

%% The core replace function

function r = do_replace(s, sp, ep, s2)

nr = numel(sp);
if ischar(s2)
    s2 = repmat({s2}, [1, nr]);
end

s1 = cell(1, nr + 1);
p = 1;
for i = 1 : nr
    if p < sp(i)
        s1{i} = s(p:sp(i)-1);
    end            
    p = ep(i)+1;
end
if p <= length(s)
    s1{nr+1} = s(p:end);
end

ss = cell(1, 2*nr+1);
ss(1:2:end) = s1;
ss(2:2:end) = s2;

r = [ss{:}];
if isempty(r)
    r = '';
end


