function obj = compileDynamics(obj)
    % This function compile the symbolic expressions of natural
    % dynamics of the rigid body model in Mathematica.
    %
    % @attention initialize(obj) must be called before run this function.
    
    
    flag = '$ModelInitialized';
    
    
    if ~checkFlag(obj, flag)
        fprintf('The robot model has NOT been initialized in Mathematica.\n');
        fprintf('Please call initialize(robot) first\n');
        fprintf('Aborting ...\n');
        return;
    end
    
    
    disp('Compiling expressions of rigid body dynamics might take very long time to finish!')
    y = input ('Hit enter to continue (or "n" to quit): ', 's');
    
    if (isempty (y))
        y = 'y' ;
    end
    
    if ~ (y (1) ~= 'n') 
        fprintf('Aborting ...\n');
        return;
    end
    
    
    
    
    if check_var_exist({'De','Ce','Ge'})
        fprintf('The dynamics functions have been compiled earlier. Do you wish to compile them again?\n');
        y = input ('Hit enter to continue (or "n" to quit): ', 's');
    
        if (isempty (y))
            y = 'y' ;
        end
        
        if ~ (y (1) ~= 'n')
            fprintf('Aborting ...\n');
            return;
        end
    end
    
    
    
    
    
    %| @note Actuator inertia! To include the actuators inertia in the
    %De matrix, use syntax:
    %  @verbatim math('De=InertiaMatrix[',cell2tensor(motor_inertia),'];'); @endverbatim
    %
    %| @note The @verbatim 'motor_inertia' @endverbatim is a 2-D cell
    %array of name/value pairs. The length must be the same as the
    %total number of joints (excludes base coordinates). For example
    %{{name1,value1},{name2,value2},...,{nameN,valueN}}.
    disp('Compiling De_mat ...');
    tic
    eval_math('De=InertiaMatrix[];');
    toc
    
    
    disp('Compiling Ce_mat ...');
    tic
    eval_math('Ce=InertiaToCoriolis[De];');
    toc
    
    disp('Compiling Ge_vec ...');
    tic
    eval_math('Ge=GravityVector[];');
    toc
    
    
    
    
    
end
