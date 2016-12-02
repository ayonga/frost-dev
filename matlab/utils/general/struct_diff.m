%> @brief Compare two different structures and provide information on their
%> differences
%> @author Eric Cousineau <eacousineau@gmail.com>
%> @author Carlos DeLa Guardia
function [] = struct_diff(A, B, verbosity, tolerance, errMode)

errTolMsg = '    Tolerances are set to relTol = %1.0e, absTol = %1.0e.\n';
exprMsg = '    Expression: %s\n';
maxDiffMsg = '    Biggest Difference: %s(%d, %d) = {%1.6e, %1.6e}\n';
magDiffMsg = '    Magnitude Difference: %g\n';

similarMsg = '[+] PASS: Both results are similar.\n';

tolOverMsg = '[-] FAIL: %s has error %g (> %1.0e)\n';
diffSizeMsg = '[-] FAIL: Different sizes: size(A) = %s, size(B) = %s.\n';
nonCellMsg = ['[-] FAIL: One (or both) of these things is neither ' ...
    'numeric nor a cell.\n'];

passMsg = '[+] PASS: All tests passed.\n';
failMsg = '[-] FAIL: The following test(s) failed:%s\n';
allWarnMsg = '[*] WARN: The following test(s) produced warning(s): %s\n';
emptyMsg = '[*] WARN: The field %s is empty in %s.\n';
warnMsg = '[*] WARN: Fields not in %s: %s';

failList = {};
warnList = {};

% Set display options
if nargin < 3 || isempty(verbosity)
    verbosity = 4;
end
if nargin < 4 || isempty(tolerance)
    tolerance = 1e-9;
end
if nargin < 5
    errMode = 'warn';
end

absTol = tolerance;
relTol = 1e-8;

% Set fieldnames
fieldsA = fieldnames(A);
fieldsB = fieldnames(B);
fieldsBoth = intersect(fieldsA, fieldsB);

printRule;

disp('Comparing struct fields:');

if verbosity > 2
    fprintf(errTolMsg,relTol, absTol);
end

% Iterate and take diff for each field
for i = 1:length(fieldsBoth)
    warn = false;
    good = false;
    printRule('-');
    field = fieldsBoth{i};
    valA = A.(field);
    valB = B.(field);
    fprintf(exprMsg, field);
    
    % Check size of each object
    sizeA = size(valA);
    sizeB = size(valB);
    if ~all(sizeA == sizeB)
        % If sizes aren't the same, but they're both vectors of the same
        % length, make them column vectors
        if isvector(valA) && isvector(valB) && length(valA) == length(valB)
            valA = valA(:);
            valB = valB(:);
        else
            fprintf(2, diffSizeMsg, ...
                mat2str(sizeA), mat2str(sizeB));
            warn = true;
            warnList{1, end+1} = field;
            continue;
        end
    end
    
    % Compare based on type
    if isnumeric(valA) && isnumeric(valB)
        valA = {valA};
        valB = {valB};
    elseif ~(iscell(valA) && iscell(valB))
        fprintf(nonCellMsg);
        warn = true;
        warnList{1, end+1} = field;
        continue;
    end
    
    good = true;
    count = length(valA);
    
    for k = 1:count
        % Check if expression contained within the field is empty in
        % either struct.
        warn = false;
        emptyStr = [];
        if isempty(valA{k})
            emptyStr = 'A';
            if isempty(valB{k})
                emptyStr = 'A and B';
            end
            warn = true;
        else
            if isempty(valB{k})
                emptyStr = 'B';
                warn = true;
            end
        end
        
        if warn
            warnList{1, end+1} = field;
            if  ~isempty(emptyStr);
                fprintf(emptyMsg, field, emptyStr);
            end
            continue
        end
        
        valDiff = valA{k} - valB{k};
        magDiff = maxMag(valDiff);
        % Keep max values separate still?
        maxValue = max(maxMag(valA{k}), maxMag(valB{k}));
        
        if verbosity > 1
            [row, col] = find(max(max(abs(valDiff))) == abs(valDiff), 1);
            fprintf(maxDiffMsg, ...
                field, row, col, valA{k}(row, col), valB{k}(row, col));
            
        end
        
        if verbosity > 0
            fprintf(magDiffMsg, magDiff);
        end
        
        tols = max(abs(valA{k}), abs(valB{k}))*relTol;
        foo = abs(valDiff);
        barRel =  foo - tols;
        barAbs = foo - absTol;
        [rowRel, colRel] = find(barRel == max(barRel(:)), 1);
        [rowAbs, colAbs] = find(barAbs == max(barAbs(:)), 1);
        curGood = (barRel(rowRel, colRel) <= 0 | ...
            barAbs(rowAbs, colAbs) <= 0);
        if verbosity > 2
            if barRel(rowRel, colRel) > barAbs(rowAbs, colAbs)
                violationMaximum = foo(rowRel, colRel);
                violationTolerance = tols(rowRel, colRel);
            else
                violationMaximum = foo(rowAbs, colAbs);
                violationTolerance = absTol;
            end
            if ~isempty(curGood)
                assert_ex(curGood, tolOverMsg, ...
                    field, violationMaximum, violationTolerance);
            end
        end
        good = all(curGood & good);
    end
    
    if ~warn
        if good
            fprintf(similarMsg)
        else
            failList{1, end+1} = field;
        end
    end
end

printRule;

% Show fields not found in both compared objects
missingA = setdiff(fieldsB, fieldsA);
missingB = setdiff(fieldsA, fieldsB);
if ~isempty(missingA)
    fprintf(warnMsg, 'A', yaml_dump(missingA));
end

if ~isempty(missingB)
    fprintf(warnMsg, 'B', yaml_dump(missingB));
end

if ~isempty(warnList)
    fprintf(2, allWarnMsg, sprintf('%s %s.', ...
        sprintf(' %s,', warnList{1:end-1}), ...
        warnList{end}));
end

if isempty(failList)
    fprintf(passMsg);
else
    fprintf(2, failMsg, sprintf('%s %s.', ...
        sprintf(' %s,', failList{1:end-1}), ...
        failList{end}));
end
printRule;

    function [valDiff, maxValue] = calc(valA, valB)
    end

    function printRule(cha)
        if nargin == 0 || ~ischar(cha)
            cha = '=';
        end
        fprintf('%s\n', repmat(cha, 1, 80))
    end

    function [] = assert_ex(expr, varargin)
        if ~isempty(errMode) && ~expr
            if strcmp(errMode, 'warn')
                fprintf([varargin{1}], varargin{2:end});
            else
                error('amber:struct_diff', varargin{:});
            end
        end
    end

    function val = maxMag(x)
        val = max(max(abs(x)));
    end
end