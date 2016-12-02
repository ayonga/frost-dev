function [str] = struct2assoc(s, varargin)
    % Converts a Matlab structure into a string that describes an
    % expression for Mathematica association
    %
    % @author ayonga
    %
    % Copyright (c) 2016, AMBER Lab
    % All right reserved.
    %
    % Redistribution and use in source and binary forms, with or without
    % modification, are permitted only in compliance with the BSD 3-Clause
    % license, see
    % http://www.opensource.org/licenses/bsd-license.php
    
    fields = fieldnames(s);
    nfield = length(fields);
    
    field_strs = cell(nfield, 1);
    for i = 1:nfield
        field = fields{i};
        value = s.(field);
        value_str = general2math(value, varargin{:});
%         if iscell(value)
%             % Use double-braces to prevent a struct array from being created
%             value_str = ['{', value_str, '}'];
%         end
        field_strs{i} = [field, '->', value_str];
    end
    
    str = ['<| ', ...
        implode(field_strs,', '), ...
        ' |>'];
end