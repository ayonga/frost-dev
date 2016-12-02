function status = checkFlag(obj, flag)
    % This function checks the flag in Mathematica's RobotModel package.
    %
    % Parameters:
    %  flag: a string of the flag @type char
    %
    % Return values:
    %  status: returns the flag status. @type logical
    
    ret = math(['GetFlag[',str2math(flag),']']);
    
    if strcmp(flag,ret)
        warning('The flag not found: %s',flag);
    end
    
    if strcmp(ret,'True')
        status = true;
    else 
        status = false;
    end
    
end
