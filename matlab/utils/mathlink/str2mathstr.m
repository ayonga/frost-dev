function expr = str2mathstr(s, varargin)
    % Converts a Matlab string to a Mathematica string
    %
    % @author ayonga @date 2016-11-23
    %
    % varargin: conversion options.     
    % ConvertString: If false, this will keep the character as it is, which
    % will be considered as symbolic variables in Mathematica 
    % @type logical @default true
    %
    % Copyright (c) 2016, AMBER Lab
    % All right reserved.
    %
    % Redistribution and use in source and binary forms, with or without
    % modification, are permitted only in compliance with the BSD 3-Clause
    % license, see
    % http://www.opensource.org/licenses/bsd-license.php
    
    p = inputParser;
    p.addParameter('ConvertString',true,@islogical);
    parse(p, varargin{:});
    
    if p.Results.ConvertString
        expr = ['"', s, '"'];
    else
        expr = s;
    end
    
end
