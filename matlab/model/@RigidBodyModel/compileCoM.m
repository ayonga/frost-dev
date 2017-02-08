function obj = compileCoM(obj)
    % This function compile the symbolic expressions of the center of mass
    % position and first order Jacobian.
    %
    % @attention initialize(obj) must be called before run this function.
    
    %     disp('Compiling expressions of CoM probably will NOT take very long time to finish!')
    %     y = input ('Hit enter to continue (or "n" to quit): ', 's');
    %
    %     if (isempty (y))
    %         y = 'y' ;
    %     end
    %     do_compile = (y (1) ~= 'n') ;
    
    
    flag = '$ModelInitialized';
        
    if ~ checkFlag(obj, flag)
        fprintf('The robot model has NOT been initialized in Mathematica.\n');
        fprintf('Please run: "initialize(%s)" in the command window.\n', obj.Name);
        fprintf('Aborting ...\n');
        return;
    end
    
    tic
    math('pcom=ComputeComPosition[];');
    math('Jcom=ComputeKinJacobians[pcom];');
    math('dJcom=D[Jcom,t];');
    toc
end
