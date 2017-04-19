function [str] = struct2assoc(s, varargin)
    % Converts a Matlab structure into a string that describes an
    % expression for Mathematica association
    %
    % @author ayonga @date 2016-11-23
    %
    % Copyright (c) 2016, AMBER Lab
    % All right reserved.
    %
    % Redistribution and use in source and binary forms, with or without
    % modification, are permitted only in compliance with the BSD 3-Clause
    % license, see
    % http://www.opensource.org/licenses/bsd-license.php
    
    if length(s) == 1 % a scalar structure
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
            field_strs{i} = [str2mathstr(field), '->', value_str];
        end
        
        str = ['<| ', ...
            implode(field_strs,', '), ...
            ' |>'];
    elseif length(s) > 1 % structure array
        expr_s = arrayfun(@(y)struct2assoc(y, varargin{:}),s,'UniformOutput',false);
        str = cell2tensor(expr_s,'ConvertString',false);
    end
        
    
end
